import 'dart:convert';
import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/line_indicator.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/utils/log.dart';
import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class LyricBuilder extends ConsumerStatefulWidget {
  const LyricBuilder({super.key});

  @override
  ConsumerState<LyricBuilder> createState() => _LrcBuilderState();
}

class _LrcBuilderState extends ConsumerState<LyricBuilder> {
  bool _hasLyric = false;
  bool _readLyric = false;

  @override
  Widget build(BuildContext context) {
    final playingViPath = ref.watch(
        voiceItemProvider.select((state) => state.cachedPlayingVoiceItemPath!));

    // 歌词文字颜色: 普通歌词跟随文字颜色设置 (独立设置时用固定色),
    // 当前行高亮固定随主题色 (后续可能单独出歌词颜色调整)
    final text = ref.watch(textColorProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final isCustom = text != null && text.mode == TEXT_MODE_CUSTOM;
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    // 当前行未播放部分与其他行同色 (defaultColor 默认纯白太突兀)
    final lineColor = ts?.lyricColor?.resolve(
            scheme.onSurface.withValues(alpha: 0.55), themeHue) ??
        (isCustom
            ? text.color.withValues(alpha: 0.62)
            : scheme.onSurface.withValues(alpha: 0.55));
    // 高亮歌词色: 用户设置优先; 否则自动 (主题色相, 饱和 0.7 明度 0.9)
    final highlightColor = ts?.lyricHighlightColor?.resolve(
            scheme.primary, themeHue) ??
        HSVColor.fromAHSV(1, themeHue.hue, 0.7, 0.9).toColor();
    final lyricUi = UINetease(
      defaultSize: ts?.lyricSize ?? 18,
      otherMainSize: (ts?.lyricSize ?? 18) - 2,
      defaultColor: lineColor,
      defaultExtColor: lineColor.withValues(alpha: 0.55),
      otherMainColor: lineColor,
      highLightTextColor: highlightColor,
      lineGap: ts?.lyricLineGap ?? 25,
      lyricAlign:
          ts?.lyricAlign == 'left' ? LyricAlign.LEFT : LyricAlign.CENTER,
    );

    final appSize = MediaQuery.of(context).size;
    final width = appSize.width * 0.70;
    final height = appSize.height - 210.0;

    // 歌词区上下边缘渐隐, 营造沉浸感
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent
        ],
        stops: [0.0, 0.14, 0.86, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: SizedBox(
        width: width,
        height: height,
        child: FutureBuilder<String>(
          future: _getLrcContent(playingViPath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading lyrics'));
            } else {
              try {
                final lrcContent = snapshot.data ?? '';
                final cachedLyricModel = _getLrcModel(lrcContent);
                return Consumer(
                  builder: (_, WidgetRef ref, __) {
                    final position = ref
                        .watch(audioProvider.select((state) => state.position));
                    final isPlaying = ref.watch(
                        audioProvider.select((state) => state.isPlaying));
                    return LyricsReader(
                      model: cachedLyricModel,
                      position: position.inMilliseconds,
                      playing: isPlaying,
                      emptyBuilder: () => EmptyLyric(
                        haveLyric: _hasLyric,
                        readLyric: _readLyric,
                      ),
                      selectLineBuilder: (position, flashBack, confirmPlay) =>
                          LineIndicator(
                        context: context,
                        position: position,
                        flashBack: flashBack,
                        confirmPlay: confirmPlay,
                        isPlaying: isPlaying,
                      ),
                      lyricUi: lyricUi,
                      waitMilliseconds: 5000,
                      canScrollBack: isPlaying,
                      canFlashBack: true,
                    );
                  },
                );
              } catch (e) {
                Log.error('Error parsing lyrics: $e');
                return const EmptyLyric(
                  haveLyric: true,
                  readLyric: false,
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<String> _getLrcContent(String playingViPath) async {
    // 定义可能的扩展名优先级
    final oldExt = p.extension(playingViPath);
    final extensions = ['.lrc', '$oldExt.lrc', '.vtt', '$oldExt.vtt', '.qrc'];

    File? targetFile;
    String? foundPath;

    // 1. 依次尝试查找文件
    for (var ext in extensions) {
      final path = p.setExtension(playingViPath, ext);
      final file = File(path);
      if (await file.exists()) {
        targetFile = file;
        foundPath = path;
        break;
      }
    }

    // 2. 如果都没找到
    if (targetFile == null) {
      _hasLyric = false;
      _readLyric = false;
      return '';
    }

    // 3. 开始读取找到的文件
    try {
      _hasLyric = true;
      final bytes = await targetFile.readAsBytes();

      // 使用 charset 探测编码（处理 GBK 等老旧 LRC 编码）
      final encoding = Charset.detect(bytes) ?? utf8;
      final result = encoding.decode(bytes);

      _readLyric = true;
      return result;
    } catch (e) {
      // 这里的错误通常是权限或文件损坏
      Log.error('Error reading lyric file: $foundPath\n'
          'unhandled error: $e');
      _readLyric = false;
      return '';
    }
  }

  LyricsReaderModel _getLrcModel(String lrcContent) {
    return LyricsModelBuilder.create().bindLyricToMain(lrcContent).getModel();
  }
}
