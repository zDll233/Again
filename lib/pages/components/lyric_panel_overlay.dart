import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:again/common/const.dart';
import 'package:again/pages/lyric/lrc_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// 窄屏歌词面板层 (MyApp Stack 最顶层): 面板从底部滑入,
/// 拖动跟随手势, 松手按速度/位置决定开合。
/// 必须放在播放器之上 — 上划歌词时面板盖住悬浮胶囊。
class LyricPanelOverlay extends ConsumerStatefulWidget {
  const LyricPanelOverlay({super.key});

  @override
  ConsumerState<LyricPanelOverlay> createState() => _LyricPanelOverlayState();
}

class _LyricPanelOverlayState extends ConsumerState<LyricPanelOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lyricAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  @override
  void initState() {
    super.initState();
    // 动画驱动 provider (面板位置跟随动画)
    _lyricAnim.addListener(() {
      final p = _lyricAnim.value;
      if ((ref.read(lyricPanelProgressProvider) - p).abs() > 0.001) {
        ref.read(lyricPanelProgressProvider.notifier).state = p;
      }
    });
    // 动画完成/取消后清空动画请求 (避免同值不触发)
    _lyricAnim.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        debugPrint('[LPO] anim ${status.name} value=${_lyricAnim.value}');
        ref.read(lyricPanelAnimateRequestProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _lyricAnim.dispose();
    super.dispose();
  }

  /// 从当前进度动画到 [target]。
  void _animateTo(double target) {
    _lyricAnim.value = ref.read(lyricPanelProgressProvider);
    debugPrint('[LPO] animateTo $target from ${_lyricAnim.value}');
    _lyricAnim.animateTo(target);
  }

  /// 松手后按速度/位置决定开合: 高速上滑打开 / 高速下滑关闭 / 低速看位置。
  bool _decideOpen(double velocity, double progress) {
    if (velocity < -300) return true;
    if (velocity > 300) return false;
    return progress >= 0.35;
  }

  void _decide(DragEndDetails details) {
    final open = _decideOpen(
        details.primaryVelocity ?? 0, ref.read(lyricPanelProgressProvider));
    final show = ref.read(miscUIProvider).showLyricPanel;
    if (open != show) {
      ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
    } else {
      _animateTo(open ? 1.0 : 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLyricPanel =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));
    final progress = ref.watch(lyricPanelProgressProvider);

    // showLyricPanel 变化 → 动画开合 (从当前进度开始)
    ref.listen(miscUIProvider.select((state) => state.showLyricPanel),
        (prev, next) {
      _animateTo(next ? 1.0 : 0.0);
    });
    // 外部动画请求 (播放器松手决定) → 动画
    ref.listen(lyricPanelAnimateRequestProvider, (prev, next) {
      if (next == null) return;
      _animateTo(next);
    });

    final screenHeight = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (!showLyricPanel) return;
        ref.read(lyricPanelProgressProvider.notifier).state =
            (progress - (details.primaryDelta ?? 0) / screenHeight)
                .clamp(0.0, 1.0);
      },
      onVerticalDragEnd: _decide,
      child: ClipRect(
        child: Transform.translate(
          // 用屏幕高度平移 (面板比屏幕矮, FractionalTranslation 按
          // 自身高度平移会露出面板顶部)
          offset: Offset(0, screenHeight * (1 - progress)),
          child: ClipRect(
            child: const _LyricPanelSurface(),
          ),
        ),
      ),
    );
  }
}

/// 面板内容独立于拖动进度构建, 拖动时只合成平移层, 避免整棵歌词树逐帧重建。
class _LyricPanelSurface extends StatelessWidget {
  const _LyricPanelSurface();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: ClipRect(child: _BlurredCoverBackground()),
          ),
          // 暗色遮罩: 保证前景文字/封面清晰可读
          ColoredBox(color: Colors.black.withValues(alpha: 0.42)),
          SafeArea(
            child: LyricPanel(
              topInset: MediaQuery.paddingOf(context).top,
            ),
          ),
        ],
      ),
    );
  }
}

/// 沉浸式背景: 当前播放作品的封面模糊铺满全屏 (参考播放器风格)。
/// 无封面时显示纯面板色 (上层遮罩仍保证文字可读)。
class _BlurredCoverBackground extends ConsumerWidget {
  const _BlurredCoverBackground();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workPath = ref.watch(voiceItemProvider
        .select((state) => state.cachedPlayingItem?.voiceWorkPath));
    if (workPath == null || workPath.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<String>(
      future: _findCover(workPath),
      builder: (context, snapshot) {
        final cover = snapshot.data ?? '';
        if (cover.isEmpty || !File(cover).existsSync()) {
          return const SizedBox.shrink();
        }
        return Image(
          image: FileImage(File(cover)),
          fit: BoxFit.cover,
          // 模糊: 低分辨率解码 + 高斯模糊, 大模糊半径下细节不可见
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) return child;
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: child,
            );
          },
        );
      },
    );
  }

  /// 作品目录下递归第一张图 (与 LyricBuilder 相同的封面查找规则)。
  Future<String> _findCover(String workPath) async {
    final dir = Directory(workPath);
    if (!dir.existsSync()) return '';
    try {
      for (final e in dir.listSync(recursive: true)) {
        if (e is File &&
            IMG_EXTENSIONS.contains(p.extension(e.path).toLowerCase())) {
          return e.path;
        }
      }
    } catch (_) {
      return '';
    }
    return '';
  }
}
