package com.zdl.again

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Process

/**
 * 自研播放引擎: MediaExtractor 解封装 + MediaCodec 解码成 PCM + AudioTrack 输出。
 *
 * 为什么要自己写播放器: 播放中实时对调左右声道必须拿到解码后的 PCM 采样
 * 再自己写进输出, just_audio (ExoPlayer) 是黑盒解码 + 直接输出, 既拿不到
 * 采样也没有左右声道重定向的 API (只能改整体音量)。
 *
 * 线程模型: 解码/写入都在内部解码线程; 平台线程只读写 volatile 字段。
 * [setSource] 立即返回, 准备结果通过 [status] 的 loading/error 反映,
 * 因此不会长时间堵住 Flutter 平台线程。
 *
 * 状态码与 Dart 侧 AudioPlaybackState 一一对应。
 */
class AgainAudioEngine {
    companion object {
        const val STATE_STOPPED = 0
        const val STATE_PLAYING = 1
        const val STATE_PAUSED = 2
        const val STATE_COMPLETED = 3

        private const val SEEK_NONE = -1L

        /** 停止/换源时等待解码线程退出的上限 (它可能阻塞在 write)。 */
        private const val JOIN_TIMEOUT_MS = 800L
    }

    @Volatile private var playing = false
    @Volatile private var channelSwap = false
    @Volatile private var volume = 1.0f
    @Volatile private var state = STATE_STOPPED
    @Volatile private var loading = false
    @Volatile private var errorMessage: String? = null
    @Volatile private var durationMs = 0L
    @Volatile private var basePositionMs = 0L
    @Volatile private var sampleRate = 44100
    @Volatile private var channelCount = 2

    @Volatile private var seekRequestMs = SEEK_NONE
    @Volatile private var sessionRunning = false
    @Volatile private var audioTrack: AudioTrack? = null
    @Volatile private var framesWritten = 0L

    /**
     * 会话令牌: 换源/释放时递增, 解码线程发现令牌变化就退出。
     * 只靠 [sessionRunning] 不够 — 旧线程若因阻塞写没能及时退出,
     * 新会话把标志重新置 true 后它会"复活"成第二个解码线程。
     */
    @Volatile private var sessionToken = 0

    private var decodeThread: Thread? = null
    private val sessionLock = Any()

    // ---------------------------------------------------------------------
    // 平台线程 API
    // ---------------------------------------------------------------------

    /** 异步加载音源; 返回是否接受了请求 (实际准备结果看 status)。 */
    fun setSource(path: String): Boolean {
        if (path.isEmpty()) return false
        stopSession()

        errorMessage = null
        loading = true
        state = STATE_STOPPED
        playing = false
        durationMs = 0L
        basePositionMs = 0L
        seekRequestMs = SEEK_NONE
        framesWritten = 0L
        sessionRunning = true
        val token = ++sessionToken

        synchronized(sessionLock) {
            decodeThread = Thread({ decodeLoop(path, token) }, "again-audio-decode").apply {
                start()
            }
        }
        return true
    }

    fun play() {
        if (state == STATE_COMPLETED) {
            // 播放结束后再按播放: 从头重播
            seekRequestMs = 0L
            basePositionMs = 0L
        }
        playing = true
        if (!loading) {
            state = STATE_PLAYING
        }
        safeTrackCall {
            if (it.playState != AudioTrack.PLAYSTATE_PLAYING) it.play()
        }
    }

    fun pause() {
        playing = false
        if (state == STATE_PLAYING) {
            state = STATE_PAUSED
        }
        safeTrackCall { it.pause() }
    }

    fun stop() {
        playing = false
        state = STATE_STOPPED
        basePositionMs = 0L
        seekRequestMs = 0L
    }

    fun seek(positionMs: Long) {
        val target = positionMs.coerceAtLeast(0L)
            .let { if (durationMs > 0 && it > durationMs) durationMs else it }
        basePositionMs = target
        seekRequestMs = target
        // 立刻冻结输出并清空缓冲, 让可能阻塞在 write() 里的解码线程返回,
        // 进入 seek 分支后重新定位。
        safeTrackCall { it.pause() }
        safeTrackCall { it.flush() }
    }

    fun setVolume(value: Float) {
        volume = value.coerceIn(0.0f, 1.0f)
        safeTrackCall { it.setVolume(volume) }
    }

    /** 实时对调左右声道: 只影响之后的写入, 不打断播放和进度。 */
    fun setChannelSwap(swap: Boolean) {
        channelSwap = swap
    }

    fun release() {
        stopSession()
        playing = false
        state = STATE_STOPPED
        durationMs = 0L
        basePositionMs = 0L
        framesWritten = 0L
        seekRequestMs = SEEK_NONE
    }

    fun status(): Map<String, Any?> = mapOf(
        "position" to currentPositionMs(),
        "duration" to durationMs,
        "state" to state,
        "loading" to loading,
        "error" to errorMessage,
    )

    // ---------------------------------------------------------------------
    // 会话生命周期
    // ---------------------------------------------------------------------

    private fun stopSession() {
        sessionRunning = false
        // 让可能还活着的旧解码线程看到令牌变化后退出
        sessionToken++
        loading = false
        releaseAudioTrack()
        val thread = synchronized(sessionLock) {
            val current = decodeThread
            decodeThread = null
            current
        }
        if (thread != null && thread.isAlive) {
            try {
                thread.join(JOIN_TIMEOUT_MS)
            } catch (_: InterruptedException) {
            }
        }
        audioTrack = null
    }

    private fun releaseAudioTrack() {
        val track = audioTrack
        audioTrack = null
        if (track != null) {
            try {
                track.pause()
            } catch (_: IllegalStateException) {
            }
            try {
                track.flush()
            } catch (_: IllegalStateException) {
            }
            try {
                track.release()
            } catch (_: IllegalStateException) {
            }
        }
    }

    private fun safeTrackCall(action: (AudioTrack) -> Unit) {
        val track = audioTrack ?: return
        try {
            action(track)
        } catch (_: IllegalStateException) {
        }
    }

    private fun currentPositionMs(): Long {
        val track = audioTrack
        val rate = if (sampleRate > 0) sampleRate else 44100
        val playedFrames = if (track == null) {
            0L
        } else {
            try {
                track.playbackHeadPosition.toLong() and 0xFFFFFFFFL
            } catch (_: IllegalStateException) {
                0L
            }
        }
        val position = basePositionMs + playedFrames * 1000L / rate
        return when {
            durationMs > 0 && position > durationMs -> durationMs
            position < 0 -> 0L
            else -> position
        }
    }

    // ---------------------------------------------------------------------
    // 解码线程
    // ---------------------------------------------------------------------

    private fun decodeLoop(path: String, token: Int) {
        Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO)
        // 可空引用只给 finally 清理用; 主流程用非空局部变量,
        // 避免 Kotlin 对被 lambda 捕获的 var 拒绝智能转换。
        var extractorRef: MediaExtractor? = null
        var codecRef: MediaCodec? = null
        var trackRef: AudioTrack? = null
        var inputDone = false
        var outputDone = false

        try {
            val source = MediaExtractor()
            extractorRef = source
            source.setDataSource(path)

            val trackIndex = (0 until source.trackCount).firstOrNull { index ->
                source.getTrackFormat(index)
                    .getString(MediaFormat.KEY_MIME)
                    ?.startsWith("audio/") == true
            } ?: throw IllegalStateException("文件中没有音频流")
            source.selectTrack(trackIndex)

            val format = source.getTrackFormat(trackIndex)
            val mime = format.getString(MediaFormat.KEY_MIME)
                ?: throw IllegalStateException("未知音频编码")
            if (format.containsKey(MediaFormat.KEY_DURATION)) {
                durationMs = format.getLong(MediaFormat.KEY_DURATION) / 1000L
            }
            sampleRate = if (format.containsKey(MediaFormat.KEY_SAMPLE_RATE)) {
                format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            } else {
                44100
            }
            channelCount = if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) {
                format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            } else {
                2
            }

            val decoder = MediaCodec.createDecoderByType(mime)
            codecRef = decoder
            decoder.configure(format, null, null, 0)
            decoder.start()

            var track: AudioTrack = createTrack(sampleRate, channelCount)
            trackRef = track
            audioTrack = track
            if (playing) {
                track.play()
                state = STATE_PLAYING
            }
            loading = false

            val bufferInfo = MediaCodec.BufferInfo()
            while (sessionRunning && token == sessionToken) {
                val pendingSeek = seekRequestMs
                if (pendingSeek != SEEK_NONE) {
                    seekRequestMs = SEEK_NONE
                    source.seekTo(
                        pendingSeek * 1000L,
                        MediaExtractor.SEEK_TO_PREVIOUS_SYNC,
                    )
                    decoder.flush()
                    inputDone = false
                    outputDone = false
                    val actual = source.sampleTime.let {
                        if (it >= 0) it / 1000L else pendingSeek
                    }
                    basePositionMs = actual
                    framesWritten = 0L
                    try {
                        track.stop()
                    } catch (_: IllegalStateException) {
                    }
                    try {
                        track.flush()
                    } catch (_: IllegalStateException) {
                    }
                    if (playing) track.play()
                }

                if (!playing) {
                    Thread.sleep(10L)
                    continue
                }

                if (!inputDone) {
                    val inputIndex = decoder.dequeueInputBuffer(10_000L)
                    if (inputIndex >= 0) {
                        val inputBuffer = decoder.getInputBuffer(inputIndex)
                        val sampleSize = if (inputBuffer == null) {
                            -1
                        } else {
                            source.readSampleData(inputBuffer, 0)
                        }
                        if (sampleSize < 0) {
                            decoder.queueInputBuffer(
                                inputIndex, 0, 0, 0L,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM,
                            )
                            inputDone = true
                        } else {
                            decoder.queueInputBuffer(
                                inputIndex, 0, sampleSize, source.sampleTime, 0,
                            )
                            source.advance()
                        }
                    }
                }

                when (val outputIndex = decoder.dequeueOutputBuffer(bufferInfo, 10_000L)) {
                    MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        val outputFormat = decoder.outputFormat
                        val rate = if (outputFormat.containsKey(MediaFormat.KEY_SAMPLE_RATE)) {
                            outputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                        } else {
                            sampleRate
                        }
                        val channels =
                            if (outputFormat.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) {
                                outputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                            } else {
                                channelCount
                            }
                        if (rate != sampleRate || channels != channelCount) {
                            // 输出格式变化: 保留当前位置, 重建 AudioTrack
                            basePositionMs = currentPositionMs()
                            framesWritten = 0L
                            try {
                                track.stop()
                                track.release()
                            } catch (_: IllegalStateException) {
                            }
                            sampleRate = rate
                            channelCount = channels
                            track = createTrack(rate, channels)
                            trackRef = track
                            audioTrack = track
                            if (playing) track.play()
                        }
                    }

                    MediaCodec.INFO_TRY_AGAIN_LATER -> Unit

                    else -> {
                        if (outputIndex >= 0) {
                            val outputBuffer = decoder.getOutputBuffer(outputIndex)
                            if (outputBuffer != null && bufferInfo.size > 0) {
                                outputBuffer.position(bufferInfo.offset)
                                outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                                val size = bufferInfo.size
                                val written = if (channelSwap && channelCount == 2) {
                                    // MediaCodec 的解码输出 ByteBuffer 是只读的, 不能就地
                                    // 交换 (会抛 ReadOnlyBufferException 直接把解码线程带崩),
                                    // 先拷进可复用数组里交换再写。
                                    val scratch = ensureScratch(size)
                                    outputBuffer.get(scratch, 0, size)
                                    swapStereoInPlace(scratch, size)
                                    track.write(scratch, 0, size, AudioTrack.WRITE_BLOCKING)
                                } else {
                                    track.write(
                                        outputBuffer,
                                        size,
                                        AudioTrack.WRITE_BLOCKING,
                                    )
                                }
                                if (written > 0) {
                                    framesWritten += written / (channelCount * 2L)
                                } else if (written < 0 && token == sessionToken) {
                                    throw IllegalStateException("音频写入失败 ($written)")
                                }
                            }
                            decoder.releaseOutputBuffer(outputIndex, false)
                            if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                                outputDone = true
                            }
                        }
                    }
                }

                if (inputDone && outputDone) {
                    break
                }
            }

            if (inputDone && outputDone && token == sessionToken) {
                waitForDrain(track, token)
                if (token == sessionToken) {
                    state = STATE_COMPLETED
                    playing = false
                }
            }
        } catch (error: Exception) {
            if (token == sessionToken) {
                errorMessage = error.message ?: error.toString()
                state = STATE_STOPPED
                playing = false
            }
        } finally {
            // 只有当前会话才能清 loading: 旧线程晚退出时不能把新会话的
            // 「准备中」误清掉 (那会让 Dart 侧提前认为音源已就绪)。
            if (token == sessionToken) {
                loading = false
            }
            try {
                codecRef?.stop()
            } catch (_: Exception) {
            }
            try {
                codecRef?.release()
            } catch (_: Exception) {
            }
            try {
                extractorRef?.release()
            } catch (_: Exception) {
            }
            if (token == sessionToken) {
                audioTrack = null
            }
            try {
                trackRef?.stop()
            } catch (_: Exception) {
            }
            try {
                trackRef?.release()
            } catch (_: Exception) {
            }
        }
    }

    /** 等 AudioTrack 把缓冲里剩下的帧放完, 再标记播放完成。 */
    private fun waitForDrain(track: AudioTrack, token: Int) {
        val deadline = System.currentTimeMillis() + 3000L
        while (sessionRunning && playing && token == sessionToken &&
            System.currentTimeMillis() < deadline
        ) {
            val played = try {
                track.playbackHeadPosition.toLong() and 0xFFFFFFFFL
            } catch (_: IllegalStateException) {
                framesWritten
            }
            if (played >= framesWritten) break
            try {
                Thread.sleep(20L)
            } catch (_: InterruptedException) {
                break
            }
        }
    }

    private fun createTrack(rate: Int, channels: Int): AudioTrack {
        val safeRate = if (rate > 0) rate else 44100
        val mask = when (channels) {
            1 -> AudioFormat.CHANNEL_OUT_MONO
            2 -> AudioFormat.CHANNEL_OUT_STEREO
            6 -> AudioFormat.CHANNEL_OUT_5POINT1
            8 -> AudioFormat.CHANNEL_OUT_7POINT1_SURROUND
            else -> AudioFormat.CHANNEL_OUT_STEREO
        }
        val minBufferSize = AudioTrack.getMinBufferSize(
            safeRate,
            mask,
            AudioFormat.ENCODING_PCM_16BIT,
        )
        val bufferSize = if (minBufferSize > 0) {
            minBufferSize * 2
        } else {
            safeRate * 2 * 2
        }
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()
        val audioFormat = AudioFormat.Builder()
            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
            .setSampleRate(safeRate)
            .setChannelMask(mask)
            .build()
        return AudioTrack.Builder()
            .setAudioAttributes(attributes)
            .setAudioFormat(audioFormat)
            .setBufferSizeInBytes(bufferSize)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()
            .also { it.setVolume(volume) }
    }

    /** 声道交换用的可复用字节缓冲 (只在解码线程里用)。 */
    private var scratch = ByteArray(0)

    private fun ensureScratch(size: Int): ByteArray {
        if (scratch.size < size) {
            scratch = ByteArray(size)
        }
        return scratch
    }

    /**
     * 就地交换 16bit PCM 的左右声道采样 (仅立体声)。
     * 按 2 字节样本为单位交换, 与字节序无关。
     */
    private fun swapStereoInPlace(data: ByteArray, size: Int) {
        var index = 0
        val last = size - 4
        while (index <= last) {
            val leftLow = data[index]
            val leftHigh = data[index + 1]
            data[index] = data[index + 2]
            data[index + 1] = data[index + 3]
            data[index + 2] = leftLow
            data[index + 3] = leftHigh
            index += 4
        }
    }
}
