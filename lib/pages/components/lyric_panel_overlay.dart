import 'package:again/pages/lyric/lrc_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        debugPrint(
            '[LPO] anim ${status.name} value=${_lyricAnim.value}');
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

    final scheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (!showLyricPanel) return;
        ref.read(lyricPanelProgressProvider.notifier).state =
            (progress - (details.primaryDelta ?? 0) / screenHeight)
                .clamp(0.0, 1.0);
      },
      onVerticalDragEnd: _decide,
      child: Transform.translate(
        // 用屏幕高度平移 (面板比屏幕矮, FractionalTranslation 按
        // 自身高度平移会露出面板顶部)
        offset: Offset(0, screenHeight * (1 - progress)),
        child: Container(
          // 全不透明: 面板必须完全盖住底层列表与播放器;
          // 全屏覆盖状态栏 (沉浸式), 内容用 SafeArea 避开状态栏/导航条
          color: scheme.surface,
          child: const SafeArea(child: LyricPanel()),
        ),
      ),
    );
  }
}
