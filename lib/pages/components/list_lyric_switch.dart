import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/lists_view.dart';
import 'package:again/pages/lyric/lrc_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListLyricSwitch extends ConsumerStatefulWidget {
  const ListLyricSwitch({super.key});

  @override
  ConsumerState<ListLyricSwitch> createState() => _ListLyricSwitchState();
}

class _ListLyricSwitchState extends ConsumerState<ListLyricSwitch>
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
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final showLyricPanel =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));
    // 面板进度: 拖动/动画的当前值
    final progress = ref.watch(lyricPanelProgressProvider);

    // showLyricPanel 变化 → 动画开合 (从当前进度开始)
    ref.listen(miscUIProvider.select((state) => state.showLyricPanel),
        (prev, next) {
      if (!isNarrow) return;
      _animateTo(next ? 1.0 : 0.0);
    });
    // 外部动画请求 (播放器松手决定) → 动画
    ref.listen(lyricPanelAnimateRequestProvider, (prev, next) {
      if (next == null || !isNarrow) return;
      _animateTo(next);
    });

    if (!isNarrow) {
      // 宽屏 (桌面): 淡入淡出切换
      // 注意: 本组件在 MyApp 的 Column 中, 必须自身返回 Expanded 撑满剩余空间
      return Expanded(
        child: Stack(
          children: [
            AnimatedOpacity(
              opacity: showLyricPanel ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Offstage(
                offstage: showLyricPanel,
                child: const ListsView(),
              ),
            ),
            AnimatedOpacity(
              opacity: showLyricPanel ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: showLyricPanel,
                child: const LyricPanel(),
              ),
            )
          ],
        ),
      );
    }

    // 窄屏: 歌词面板从底部滑入, 拖动跟随手势, 松手按速度/位置决定开合。
    // behavior 默认 deferToChild: 面板移出屏幕后不拦截下层列表的滚动。
    final scheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Expanded(
      child: Stack(
        children: [
          const ListsView(),
          GestureDetector(
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
                // 全不透明: 面板必须完全盖住底层列表
                color: scheme.surface,
                child: const LyricPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
