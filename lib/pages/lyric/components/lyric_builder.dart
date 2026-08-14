import 'dart:convert';
import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/pages/components/image_thumbnail.dart';
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
  String _lastWorkPath = '';
  String _lastCoverPath = '';

  @override
  Widget build(BuildContext context) {
    final cached = ref
        .watch(voiceItemProvider.select((state) => state.cachedPlayingItem));
    final playingViPath = cached!.filePath;
    final workPath = cached.voiceWorkPath;

    // 歌词文字颜色: 默认跟随主题的 onSurface, 可单独设置
    final scheme = Theme.of(context).colorScheme;
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    // 当前行未播放部分与其他行同色 (defaultColor 默认纯白太突兀)
    final lineColor = ts?.lyricColor?.resolve(
            scheme.onSurface.withValues(alpha: 0.55), themeHue) ??
        scheme.onSurface.withValues(alpha: 0.55);
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
    final height = appSize.height - 210.0;
    // 左右各留 10% 边距
    final contentWidth = appSize.width * 0.80;
    // 左侧封面 1:1 方形, 高度与歌词区比例
    final coverSize = height * 0.50;
    // 歌词列宽 = 内容宽 - 封面 - 间距
    final lyricWidth = contentWidth - coverSize - 28.0;

    return SizedBox(
      width: contentWidth,
      height: height,
      // 左: 封面; 右: 歌词
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<String>(
            future: _getCoverPath(workPath),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return _buildCover(snapshot.data!, coverSize);
            },
          ),
          const SizedBox(width: 28),
          Expanded(
            // 歌词区上下边缘渐隐, 营造沉浸感
            child: ShaderMask(
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
                          final position = ref.watch(audioProvider
                              .select((state) => state.position));
                          final isPlaying = ref.watch(
                              audioProvider.select((state) => state.isPlaying));
                          return LyricsReader(
                            model: cachedLyricModel,
                            position: position.inMilliseconds,
                            playing: isPlaying,
                            // 歌词行宽 < 指示条宽: 水平留白收窄歌词显示区,
                            // 而指示条 (selectLineBuilder) 仍横贯歌词列全宽;
                            // 左对齐时额外避开指示条定位图标 (25 边距+32 图标+余量)
                            padding: ts?.lyricAlign == 'left'
                                ? EdgeInsets.only(
                                    left: 80, right: lyricWidth * 0.10)
                                : EdgeInsets.symmetric(
                                    horizontal: lyricWidth * 0.10),
                            emptyBuilder: () => EmptyLyric(
                                haveLyric: _hasLyric,
                                readLyric: _readLyric,
                              ),
                            selectLineBuilder: (position, flashBack,
                                    confirmPlay) =>
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
          ),
        ],
      ),
    );
  }

  /// 封面 + 下方渐隐倒影 (镜像翻转), 点击可放大。
  Widget _buildCover(String coverPath, double size) {
    final coverFile = File(coverPath);
    final imageProvider = coverPath.isNotEmpty && coverFile.existsSync()
        ? FileImage(coverFile)
        : const AssetImage('assets/images/nocover.jpg') as ImageProvider;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheHeight = (size * dpr * 2).round();
    Widget cover(double w, double h) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image(
            image: ResizeImage(imageProvider, height: cacheHeight),
            width: w,
            height: h,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        );
    return GestureDetector(
      onTap: () => openImageDialog(context, imageProvider),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cover(size, size),
          const SizedBox(height: 6),
          // 倒影: 镜像翻转 + 自上而下渐隐, 高度取封面的 1/3
          SizedBox(
            height: size / 3,
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66FFFFFF), Colors.transparent],
                ).createShader(rect),
                blendMode: BlendMode.modulate,
                child: Opacity(
                  opacity: 0.5,
                  child: Transform.flip(flipY: true, child: cover(size, size)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 查询作品封面 (作品目录下递归第一张图), 结果按作品目录缓存。
  Future<String> _getCoverPath(String workPath) async {
    if (workPath == _lastWorkPath) return _lastCoverPath;
    _lastWorkPath = workPath;
    _lastCoverPath = _findCover(workPath);
    return _lastCoverPath;
  }

  String _findCover(String workPath) {
    final dir = Directory(workPath);
    if (!dir.existsSync()) return '';
    try {
      for (final e in dir.listSync(recursive: true)) {
        if (e is File &&
            IMG_EXTENSIONS.contains(p.extension(e.path).toLowerCase())) {
          return e.path;
        }
      }
    } catch (e) {
      Log.error('Error finding cover: $e');
    }
    return '';
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
