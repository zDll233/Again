package com.zdl.again

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        /**
         * 自研播放引擎做成单例: Activity 重建 (旋转/深浅色切换) 时
         * configureFlutterEngine 会再跑一遍, 复用同一实例才不会丢掉正在播放的音频。
         */
        private var audioEngine: AgainAudioEngine? = null

        private fun obtainAudioEngine(): AgainAudioEngine =
            audioEngine ?: AgainAudioEngine().also { audioEngine = it }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "again/installer")
            .setMethodCallHandler { call, result ->
                if (call.method == "installApk") {
                    val path = call.arguments as? String
                    if (path == null) {
                        result.error("bad_args", "path missing", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val apk = File(path)
                        val uri: Uri = FileProvider.getUriForFile(
                            this, "$packageName.fileprovider", apk,
                        )
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, "application/vnd.android.package-archive")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("install_failed", e.message, null)
                    }
                } else if (call.method == "openUrl") {
                    val url = call.arguments as? String
                    if (url == null) {
                        result.error("bad_args", "url missing", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("open_failed", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }

        // 自研播放引擎 (Dart 侧 lib/services/audio/audio_engine.dart, 同名频道的
        // Windows 实现在 windows/runner/again_audio_channel.cpp)。
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "again/audio")
            .setMethodCallHandler { call, result -> handleAudioCall(call, result) }
    }

    private fun handleAudioCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val engine = obtainAudioEngine()
        when (call.method) {
            "setSource" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("bad_args", "path missing", null)
                } else {
                    result.success(engine.setSource(path))
                }
            }
            "play" -> {
                engine.play()
                result.success(null)
            }
            "pause" -> {
                engine.pause()
                result.success(null)
            }
            "stop" -> {
                engine.stop()
                result.success(null)
            }
            "release" -> {
                engine.release()
                result.success(null)
            }
            "seek" -> {
                engine.seek(call.argument<Int>("position")?.toLong() ?: 0L)
                result.success(null)
            }
            "setVolume" -> {
                val number = call.argument<Double>("volume")
                engine.setVolume((number ?: 1.0).toFloat())
                result.success(null)
            }
            "setChannelSwap" -> {
                engine.setChannelSwap(call.argument<Boolean>("swap") ?: false)
                result.success(null)
            }
            "status" -> result.success(engine.status())
            else -> result.notImplemented()
        }
    }
}
