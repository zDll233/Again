import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:again/common/const.dart';
import 'package:again/pages/components/image_thumbnail.dart';
import 'package:again/pages/components/panel_switcher.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/lyric_panel_controls.dart';
import 'package:again/utils/log.dart';
import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class LyricBuilder extends ConsumerStatefulWidget {
  const LyricBuilder({super.key, this.topInset = 0});

  /// 状态栏高度 (SafeArea 外的真实值), 用于窄屏参考图比例定位。
  final double topInset;

  @override
  ConsumerState<LyricBuilder> createState() => _LrcBuilderState();
}

class _LrcBuilderState extends ConsumerState<LyricBuilder> {
  static const _previewColorStyleVersion = 2;

  bool _hasLyric = false;
  bool _readLyric = false;
  String _lastWorkPath = '';
  String _lastCoverPath = '';
  String _previewUiKey = '';
  UINetease? _previewUi;

  @override
  Widget build(BuildContext context) {
    final cached =
        ref.watch(voiceItemProvider.select((state) => state.cachedPlayingItem));
    final playingViPath = cached!.filePath;
    final workPath = cached.voiceWorkPath;

    // 歌词文字颜色: 默认跟随主题的 onSurface, 可单独设置
    final scheme = Theme.of(context).colorScheme;
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final appearance = ref.watch(uiSettingsProvider).valueOrNull;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    // 当前行未播放部分与其他行同色 (defaultColor 默认纯白太突兀)
    final lineColor = ts?.lyricColor
            ?.resolve(scheme.onSurface.withValues(alpha: 0.55), themeHue) ??
        scheme.onSurface.withValues(alpha: 0.55);
    // 高亮歌词色: 用户设置优先; 否则自动 (主题色相, 饱和 0.7 明度 0.9)
    final highlightColor =
        ts?.lyricHighlightColor?.resolve(scheme.primary, themeHue) ??
            HSVColor.fromAHSV(1, themeHue.hue, 0.7, 0.9).toColor();
    // 默认值统一取自 TextSettings() 构造 (单一来源)
    const lyricDefaults = TextSettings();
    final lyricUi = UINetease(
      defaultSize: ts?.lyricCurrentSize ?? lyricDefaults.lyricCurrentSize,
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
    // 窄屏 (手机竖屏): 封面/歌词改为左右滑动切换 (PanelSwitcher)
    final isNarrow = appSize.width < 600;
    // 左右边距: 左 10% (窄屏 5%), 右 5%
    final leftMargin = appSize.width * (isNarrow ? 0.05 : 0.10);
    final rightMargin = appSize.width * 0.05;

    // 高度来自父级约束 (LyricPanel Expanded), 不再假设窗口高度:
    // 窄屏下 PageView 需要有限高度, 宽屏保留原 "窗口高 - 210" 的布局
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = math.min(appSize.height - 210.0, constraints.maxHeight);
        // 封面 30% 宽 (1:1 方形), 封面-歌词间距与左边距一致 10%;
        // 高度约束: 封面列 (封面 + 倒影 1/3) 总高须 ≤ 歌词区高, 否则溢出;
        // 窄屏独占一页, 封面可以更大
        final coverSize = isNarrow
            ? math.min(appSize.width * 0.55, height * 0.60)
            : math.min(appSize.width * 0.30, height * 0.60);
        final coverGap = appSize.width * 0.10;
        // 歌词列宽 = 窗口宽 - 左边距 - 封面 - 间距 - 右边距 (窄屏独占全宽)
        final lyricWidth = isNarrow
            ? appSize.width - leftMargin - rightMargin
            : appSize.width - leftMargin - coverSize - coverGap - rightMargin;

        // 封面区 (含加载封面 + 垂直居中偏移)
        Widget coverSection(double coverSize) {
          return SizedBox(
            width: coverSize,
            child: FutureBuilder<String>(
              future: _getCoverPath(workPath),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                // 以封面本体为对象垂直居中
                return Padding(
                  padding: EdgeInsets.only(
                      top: isNarrow ? 0 : (height - coverSize) / 2),
                  child: _buildCover(
                    snapshot.data!,
                    coverSize,
                    // 倾斜/倒影仅宽屏桌面沿用设置 (窄屏移动端移除)
                    tilt: isNarrow ? false : (appearance?.coverTilt ?? true),
                    reflection: isNarrow
                        ? false
                        : (appearance?.coverReflection ?? true),
                    allowPreview: !isNarrow,
                  ),
                );
              },
            ),
          );
        }

        // 歌词区 (上下边缘渐隐, 营造沉浸感)
        Widget lyricSection() {
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
                    return _buildLyricsReader(
                      model: cachedLyricModel,
                      lyricUi: lyricUi,
                      padding: ts?.lyricAlign == 'left'
                          ? EdgeInsets.only(left: 12, right: lyricWidth * 0.10)
                          : EdgeInsets.symmetric(horizontal: lyricWidth * 0.10),
                      interactive: true,
                      emptyBuilder: () => EmptyLyric(
                        haveLyric: _hasLyric,
                        readLyric: _readLyric,
                      ),
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
          );
        }

        // 窄屏: 封面页与纯歌词页左右滑动切换 (封面区域右划看到完整歌词);
        // 布局按参考播放器截图像素比例定位 (694x1503):
        //   标题区 4.2%-10% / 封面约 18%-58% /
        //   预览约 62%-75% (底部控制区固定在 PageView 外)
        if (isNarrow) {
          final screenH = appSize.height;
          // 标题区底相对屏顶 = 状态栏 + 标题区 (标题区与 LyricPanel 一致),
          // Positioned 相对 LyricBuilder 顶 (= 标题区底), 故各区块减去它
          final titleH = math.max(screenH * 0.058, 56.0);
          final contentTop = widget.topInset + titleH;
          // Android 歌词页封面恢复原比例; 作品条目封面预览的放宽在
          // image_thumbnail.dart 的对话框中单独处理。
          final narrowCover = appSize.width * 0.849;
          final coverTop = screenH * 0.18 - contentTop;
          final previewTop = screenH * 0.62 - contentTop;
          final progressTop =
              constraints.maxHeight - 30.0 - lyricPanelControlsHeight;
          final coverPreviewGap =
              math.max(30.0, previewTop - (coverTop + narrowCover));
          final previewHeight = math.max(
            0.0,
            progressTop - previewTop - coverPreviewGap,
          );
          return PanelSwitcher(
            panels: [
              // 封面页: 封面/预览/控制区按百分比定位
              Stack(
                fit: StackFit.expand,
                children: [
                  // 封面: 18% 屏高起, 水平居中, 给三句预览留出空间
                  Positioned(
                    top: coverTop,
                    left: (appSize.width - narrowCover) / 2,
                    child: coverSection(narrowCover),
                  ),
                  // 歌词预览: 62% 屏高起
                  Positioned(
                    top: previewTop,
                    left: 0,
                    right: 0,
                    child: _buildLyricPreview(
                        playingViPath,
                        ts?.lyricPreviewColor?.resolve(lineColor, themeHue) ??
                            lineColor,
                        ts?.lyricPreviewHighlightColor
                                ?.resolve(highlightColor, themeHue) ??
                            highlightColor,
                        ts?.lyricAlign ?? 'left',
                        math.max(14.0, (ts?.lyricLineGap ?? 25.0) * 0.6),
                        ts?.lyricPreviewSize ?? 16.0,
                        ts?.lyricPreviewCurrentSize ??
                            ts?.lyricPreviewSize ??
                            16.0,
                        previewHeight),
                  ),
                ],
              ),
              // 纯歌词页: 歌词 14%-80%; 底部控制区由 LyricPanel 固定覆盖。
              Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 30.0,
                    left: 0,
                    right: 0,
                    bottom: lyricPanelControlsHeight + 60.0,
                    child: lyricSection(),
                  ),
                ],
              ),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.only(left: leftMargin, right: rightMargin),
          child: SizedBox(
            width: double.infinity,
            height: height,
            // 左: 封面; 右: 歌词
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                coverSection(coverSize),
                SizedBox(width: coverGap),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: lyricSection(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 封面 (+ 可选倒影/3D 倾斜);
  /// 无封面时显示占位图标块。Android 只负责展示, Windows 保留预览入口。
  Widget _buildCover(String coverPath, double size,
      {bool tilt = true, bool reflection = true, bool allowPreview = true}) {
    final hasCover = coverPath.isNotEmpty && File(coverPath).existsSync();
    final imageProvider =
        allowPreview && hasCover ? FileImage(File(coverPath)) : null;

    void onCoverTap() {
      if (imageProvider != null) {
        openImageDialog(context, imageProvider);
      }
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheHeight = (size * dpr * 2).round();
    Widget cover(double w, double h) {
      if (!hasCover) {
        // 无封面: 纯 UI 占位 (图标块)
        final scheme = Theme.of(context).colorScheme;
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          ),
          child: Icon(
            Icons.music_note,
            size: w * 0.4,
            color: scheme.onSurface.withValues(alpha: 0.25),
          ),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: ResizeImage(FileImage(File(coverPath)), height: cacheHeight),
          width: w,
          height: h,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      );
    }

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
                child: Transform.flip(flipY: true, child: cover(size, size)),
              ),
            ),
          ),
      ],
    );
    if (!tilt) {
      // 关闭倾斜: 直接显示封面
      return GestureDetector(
        onTap: allowPreview ? onCoverTap : null,
        child: coverBody,
      );
    }
    return _TiltCover(
      coverSize: size,
      onTap: allowPreview ? onCoverTap : null,
      child: coverBody,
    );
  }

  /// 使用右侧相同的 LyricsReader, 仅缩小字号/行距并限制显示区域。
  /// 封面预览不可滑动/点击; 对齐方式跟随设置。
  Widget _buildLyricPreview(
      String playingViPath,
      Color lineColor,
      Color highlightColor,
      String lyricAlign,
      double lineGap,
      double previewSize,
      double previewCurrentSize,
      double previewHeight) {
    return FutureBuilder<String>(
      future: _getLrcContent(playingViPath),
      builder: (context, snapshot) {
        final content = snapshot.data ?? '';
        if (content.isEmpty) return const SizedBox.shrink();
        try {
          final model = _getLrcModel(content);
          return SizedBox(
            height: previewHeight,
            child: _buildLyricsReader(
              model: model,
              lyricUi: _getPreviewUi(lineColor, highlightColor, lineGap,
                  previewSize, previewCurrentSize, lyricAlign),
              padding: lyricAlign == 'left'
                  ? const EdgeInsets.only(left: 12, right: 24)
                  : const EdgeInsets.symmetric(horizontal: 24),
              interactive: false,
            ),
          );
        } catch (e) {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /// 右侧歌词与封面预览共用的渲染入口。
  /// [interactive] 为 false 时，保留自动跟随播放与逐字高亮，但屏蔽所有输入。
  Widget _buildLyricsReader({
    required LyricsReaderModel model,
    required UINetease lyricUi,
    required EdgeInsets padding,
    required bool interactive,
    Widget? Function()? emptyBuilder,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final position =
            ref.watch(audioProvider.select((state) => state.position));
        final isPlaying =
            ref.watch(audioProvider.select((state) => state.isPlaying));
        final reader = LyricsReader(
          model: model,
          position: position.inMilliseconds,
          playing: isPlaying,
          padding: padding,
          emptyBuilder: emptyBuilder,
          onTapLine: interactive
              ? (index, startTime) {
                  ref.read(audioProvider.notifier).seek(startTime);
                  if (!isPlaying) {
                    ref.read(audioProvider.notifier).resume();
                  }
                }
              : null,
          hoverColor: interactive ? Colors.white : null,
          hoverTimeColor: interactive
              ? (ref.watch(uiSettingsProvider).valueOrNull?.showHoverTime ??
                      true)
                  ? Colors.white.withValues(alpha: 0.45)
                  : null
              : null,
          hoverTimeSize:
              ref.watch(uiSettingsProvider).valueOrNull?.hoverTimeSize ?? 14,
          rippleColor:
              interactive ? Theme.of(context).colorScheme.primary : null,
          lyricUi: lyricUi,
          waitMilliseconds: 5000,
          canScrollBack: interactive && isPlaying,
          canFlashBack: interactive,
        );
        return interactive ? reader : IgnorePointer(child: reader);
      },
    );
  }

  /// UI 实例也必须稳定, 否则 flutter_lyric 会把样式变化当成重置请求。
  UINetease _getPreviewUi(Color lineColor, Color highlightColor, double lineGap,
      double previewSize, double previewCurrentSize, String lyricAlign) {
    final key =
        '$_previewColorStyleVersion-${lineColor.toARGB32()}-${highlightColor.toARGB32()}-$lineGap-$previewSize-$previewCurrentSize-$lyricAlign';
    if (_previewUi == null || _previewUiKey != key) {
      _previewUiKey = key;
      _previewUi = UINetease(
        defaultSize: previewCurrentSize,
        otherMainSize: previewSize,
        defaultColor: lineColor,
        defaultExtColor: lineColor.withValues(alpha: 0.55),
        otherMainColor: lineColor,
        highLightTextColor: highlightColor,
        lineGap: lineGap,
        lyricAlign: lyricAlign == 'left' ? LyricAlign.LEFT : LyricAlign.CENTER,
      );
    }
    return _previewUi!;
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
/// 倒影随封面一起倾斜 (被动跟随); 点击行为由平台布局决定。
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
