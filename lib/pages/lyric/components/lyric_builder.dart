import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:again/common/const.dart';
import 'package:again/pages/components/image_thumbnail.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lyric/components/empty_lyric.dart';
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
    final appearance = ref.watch(uiSettingsProvider).valueOrNull;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    // 当前行未播放部分与其他行同色 (defaultColor 默认纯白太突兀)
    final lineColor = ts?.lyricColor?.resolve(
            scheme.onSurface.withValues(alpha: 0.55), themeHue) ??
        scheme.onSurface.withValues(alpha: 0.55);
    // 高亮歌词色: 用户设置优先; 否则自动 (主题色相, 饱和 0.7 明度 0.9)
    final highlightColor = ts?.lyricHighlightColor?.resolve(
            scheme.primary, themeHue) ??
        HSVColor.fromAHSV(1, themeHue.hue, 0.7, 0.9).toColor();
    // 默认值统一取自 TextSettings() 构造 (单一来源)
    const lyricDefaults = TextSettings();
    final lyricUi = UINetease(
      defaultSize: ts?.lyricCurrentSize ??
          (ts?.lyricSize ?? lyricDefaults.lyricSize) + 2,
      otherMainSize: ts?.lyricSize ?? lyricDefaults.lyricSize,
      defaultColor: lineColor,
      defaultExtColor: lineColor.withValues(alpha: 0.55),
      otherMainColor: lineColor,
      highLightTextColor: highlightColor,
      lineGap: ts?.lyricLineGap ?? lyricDefaults.lyricLineGap,
      lyricAlign:
          ts?.lyricAlign == 'left' ? LyricAlign.LEFT : LyricAlign.CENTER,
    );

    final appSize = MediaQuery.of(context).size;
    final height = appSize.height - 210.0;
    // 左右边距: 左 10%, 右 5%
    final leftMargin = appSize.width * 0.10;
    final rightMargin = appSize.width * 0.05;
    // 封面 30% 宽 (1:1 方形), 封面-歌词间距与左边距一致 10%;
    // 高度约束: 封面列 (封面 + 倒影 1/3) 总高须 ≤ 歌词区高, 否则溢出
    final coverSize =
        math.min(appSize.width * 0.30, height * 0.60);
    final coverGap = appSize.width * 0.10;
    // 歌词列宽 = 窗口宽 - 左边距 - 封面 - 间距 - 右边距
    final lyricWidth = appSize.width - leftMargin - coverSize - coverGap - rightMargin;

    return Padding(
      padding: EdgeInsets.only(left: leftMargin, right: rightMargin),
      child: SizedBox(
        width: double.infinity,
        height: height,
        // 左: 封面; 右: 歌词
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: coverSize,
              child: FutureBuilder<String>(
                future: _getCoverPath(workPath),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  // 以封面本体为对象垂直居中, 倒影向下延伸不参与居中
                  return Padding(
                    padding: EdgeInsets.only(top: (height - coverSize) / 2),
                    child: _buildCover(snapshot.data!, coverSize,
                        tilt: appearance?.coverTilt ?? true,
                        reflection: appearance?.coverReflection ?? true),
                  );
                },
              ),
            ),
            SizedBox(width: coverGap),
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
                            // 歌词行宽 = 歌词列 - 水平留白; 左对齐时文字起点
                            // 对齐 hover 框左缘 (行框内边距 12)
                            padding: ts?.lyricAlign == 'left'
                                ? EdgeInsets.only(
                                    left: 12, right: lyricWidth * 0.10)
                                : EdgeInsets.symmetric(
                                    horizontal: lyricWidth * 0.10),
                            emptyBuilder: () => EmptyLyric(
                                haveLyric: _hasLyric,
                                readLyric: _readLyric,
                              ),
                            // 点击歌词行跳转到该行播放
                            onTapLine: (index, startTime) {
                              ref
                                  .read(audioProvider.notifier)
                                  .seek(startTime);
                              if (!isPlaying) {
                                ref.read(audioProvider.notifier).resume();
                              }
                            },
                            // hover 行边框 (Material 风白色半透明) + 点击涟漪
                            hoverColor: Colors.white,
                            // hover 行左侧起始时间 (可开关/调字号)
                            hoverTimeColor:
                                (appearance?.showHoverTime ?? true)
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : null,
                            hoverTimeSize:
                                appearance?.hoverTimeSize ?? 14,
                            rippleColor: scheme.primary,
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
      ),
    );
  }

  /// 封面 (+ 可选倒影/3D 倾斜), 点击可放大 (无封面时不响应点击)。
  Widget _buildCover(String coverPath, double size,
      {bool tilt = true, bool reflection = true}) {
    final hasCover = coverPath.isNotEmpty && File(coverPath).existsSync();
    // 无封面: 纯 UI 占位 (图标块), 不可点击查看大图
    if (!hasCover) {
      final scheme = Theme.of(context).colorScheme;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        ),
        child: Icon(
          Icons.music_note,
          size: size * 0.4,
          color: scheme.onSurface.withValues(alpha: 0.25),
        ),
      );
    }
    final imageProvider = FileImage(File(coverPath));
    // 有封面才允许点击查看大图
    void onCoverTap() => openImageDialog(context, imageProvider);
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
    final coverBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cover(size, size),
        if (reflection)
          // 倒影: 完整 1:1 镜像 (裁剪后的方形封面翻转), 从封面底边向下延伸;
          // 用 OverflowBox 允许镜像超出显示区, dstIn 只做 alpha 渐隐 (颜色不失真)
          SizedBox(
            height: size / 3,
            child: OverflowBox(
              maxHeight: size,
              alignment: Alignment.topCenter,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.33],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child:
                    Transform.flip(flipY: true, child: cover(size, size)),
              ),
            ),
          ),
      ],
    );
    if (!tilt) {
      // 关闭倾斜: 直接显示封面
      return GestureDetector(
        onTap: onCoverTap,
        child: coverBody,
      );
    }
    return _TiltCover(
      coverSize: size,
      onTap: onCoverTap,
      child: coverBody,
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

/// 悬停 3D 倾斜封面: 鼠标在封面边缘时, 该侧向远离用户的方向倾斜,
/// 并叠加顶部光源响应 — 上半部分后仰时顶部反光变浅, 下半部分后仰时顶部变暗。
/// 倒影随封面一起倾斜 (被动跟随); 鼠标交互 (倾斜/点击) 只在封面本体上。
class _TiltCover extends StatefulWidget {
  final Widget child;
  final double coverSize;
  final VoidCallback? onTap;

  const _TiltCover({
    required this.child,
    required this.coverSize,
    this.onTap,
  });

  @override
  State<_TiltCover> createState() => _TiltCoverState();
}

class _TiltCoverState extends State<_TiltCover> {
  /// 鼠标相对封面本体的偏移 (-1..1), 0 表示回到水平。
  double _tx = 0;
  double _ty = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 整组 (封面+倒影) 倾斜
        TweenAnimationBuilder<Offset>(
          tween: Tween(begin: Offset.zero, end: Offset(_tx, _ty)),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, t, child) {
            const maxAngle = 0.12; // 约 7°
            // 鼠标在的那一侧向远离用户的方向倾斜
            final angleX = t.dy * maxAngle;
            final angleY = -t.dx * maxAngle;
            final strength = t.dy.abs().clamp(0.0, 1.0);
            // 顶部光源: 上半部分后仰 (t.dy<0) → 顶部反光变浅;
            // 下半部分后仰 (t.dy>0) → 上表面背光, 顶部变暗
            final overlay = DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: t.dy < 0
                      ? [
                          Colors.white.withValues(alpha: 0.35 * strength),
                          Colors.transparent,
                        ]
                      : [
                          Colors.black.withValues(alpha: 0.35 * strength),
                          Colors.transparent,
                        ],
                ),
              ),
            );
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(angleX)
                ..rotateY(angleY),
              child: Stack(
                children: [
                  child!,
                  // 光照遮罩只覆盖封面本体区域
                  Positioned(
                    top: 0,
                    left: 0,
                    width: widget.coverSize,
                    height: widget.coverSize,
                    child: IgnorePointer(child: overlay),
                  ),
                ],
              ),
            );
          },
          child: widget.child,
        ),
        // 鼠标交互层: 只覆盖封面本体区域 (倒影不响应)
        Positioned(
          width: widget.coverSize,
          height: widget.coverSize,
          child: MouseRegion(
            onHover: (event) {
              final tx =
                  ((event.localPosition.dx / widget.coverSize) - 0.5) * 2;
              final ty =
                  ((event.localPosition.dy / widget.coverSize) - 0.5) * 2;
              if (tx != _tx || ty != _ty) {
                setState(() {
                  _tx = tx;
                  _ty = ty;
                });
              }
            },
            onExit: (_) => setState(() {
              _tx = 0;
              _ty = 0;
            }),
            child: GestureDetector(
              // opaque: 透明区域也参与命中, 确保点击封面必响应
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
