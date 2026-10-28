// 临时真机验证入口 (不属于应用功能, 验证完删除):
//   flutter run -d <device> -t tool/engine_probe.dart
// 用生成的 WAV 走一遍自研播放引擎: 加载/播放/进度/播放中切声道/seek/暂停/释放。
// 全程音量 0 (静音), 不会发出声音。
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:again/services/audio/audio_engine.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final List<String> _lines = <String>[];
int _failures = 0;

void _check(bool condition, String message) {
  final line = condition ? '  [ok]   $message' : '  [FAIL] $message';
  if (!condition) _failures++;
  _lines.add(line);
  debugPrint('PROBE$line');
}

Future<void> _log(String text) async {
  _lines.add(text);
  debugPrint('PROBE $text');
}

Uint8List _buildStereoWav({
  required Duration duration,
  required int sampleRate,
  required double leftFrequency,
  required double rightFrequency,
}) {
  final frames = (duration.inMilliseconds * sampleRate / 1000).round();
  final dataSize = frames * 4;
  final bytes = Uint8List(44 + dataSize);
  final data = ByteData.sublistView(bytes);

  void writeAscii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      bytes[offset + i] = text.codeUnitAt(i);
    }
  }

  writeAscii(0, 'RIFF');
  data.setUint32(4, 36 + dataSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 2, Endian.little);
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 4, Endian.little);
  data.setUint16(32, 4, Endian.little);
  data.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  data.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < frames; i++) {
    final t = i / sampleRate;
    final left = (math.sin(2 * math.pi * leftFrequency * t) * 8000).round();
    final right = (math.sin(2 * math.pi * rightFrequency * t) * 8000).round();
    data.setInt16(44 + i * 4, left, Endian.little);
    data.setInt16(46 + i * 4, right, Endian.little);
  }
  return bytes;
}

Future<AudioEngineStatus?> _waitReady(AudioEngine engine) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    final status = await engine.status();
    if (status != null && !status.isLoading) return status;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  return engine.status();
}

Future<void> _runProbe() async {
  AudioEngineStatus? status;
  final engine = AudioEngine();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/again_engine_probe.wav');

  await _log('file: ${file.path}');
  await file.writeAsBytes(_buildStereoWav(
    duration: const Duration(seconds: 6),
    sampleRate: 44100,
    leftFrequency: 440,
    rightFrequency: 880,
  ));

  await engine.setVolume(0); // 静音
  _check(await engine.setSource(file.path), 'setSource 被接受');

  status = await _waitReady(engine);
  _check(status != null && !status.isLoading, 'loading 结束');
  _check(status?.error == null, '没有加载错误 (${status?.error})');
  _check(
    (status?.duration.inMilliseconds ?? 0) > 5000,
    '时长 ${status?.duration.inMilliseconds}ms',
  );

  await engine.play();
  await Future<void>.delayed(const Duration(milliseconds: 900));
  status = await engine.status();
  _check(status?.state == AudioPlaybackState.playing, '状态 = playing');
  _check((status?.position.inMilliseconds ?? 0) > 0,
      '进度推进到 ${status?.position.inMilliseconds}ms');

  final beforeSwap = status?.position ?? Duration.zero;
  await engine.setChannelSwap(true);
  await Future<void>.delayed(const Duration(milliseconds: 700));
  status = await engine.status();
  _check(status?.state == AudioPlaybackState.playing,
      '切声道后仍在播放 (error: ${status?.error})');
  _check((status?.position ?? Duration.zero) > beforeSwap,
      '切声道后进度继续 (${status?.position.inMilliseconds}ms)');
  await engine.setChannelSwap(false);

  await engine.seek(const Duration(seconds: 3));
  await Future<void>.delayed(const Duration(milliseconds: 600));
  status = await engine.status();
  final seekPosition = status?.position.inMilliseconds ?? 0;
  _check(seekPosition > 2400 && seekPosition < 5200, 'seek 后位置 ${seekPosition}ms');

  await engine.pause();
  final pausedPosition = (await engine.status())?.position ?? Duration.zero;
  await Future<void>.delayed(const Duration(milliseconds: 600));
  final pausedLater = (await engine.status())?.position ?? Duration.zero;
  final drift = (pausedLater - pausedPosition).inMilliseconds.abs();
  _check(drift < 500, '暂停后位置冻结 (漂移 ${drift}ms)');

  await engine.play();
  await Future<void>.delayed(const Duration(milliseconds: 600));
  status = await engine.status();
  _check(status?.state == AudioPlaybackState.playing, 'resume 后状态 = playing');
  _check((status?.position ?? Duration.zero) > pausedLater, 'resume 后进度继续');

  await engine.release();
  status = await engine.status();
  _check(status?.state == AudioPlaybackState.stopped, 'release 后状态 = stopped');

  await engine.dispose();
  try {
    await file.delete();
  } catch (_) {}

  await _log(_failures == 0 ? 'RESULT: PASS' : 'RESULT: FAIL ($_failures)');
}

class ProbePage extends StatefulWidget {
  const ProbePage({super.key});

  @override
  State<ProbePage> createState() => _ProbePageState();
}

class _ProbePageState extends State<ProbePage> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (_started) return;
    _started = true;
    _runProbe().whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('音频引擎自检')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final line in _lines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  line,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: line.contains('[FAIL]')
                        ? Colors.red
                        : line.contains('[ok]')
                            ? Colors.green
                            : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const ProbePage());
}
