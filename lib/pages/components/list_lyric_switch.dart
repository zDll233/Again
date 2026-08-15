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
  /// 歌词面板显示进度: 1 = 全屏显示, 0 = 完全移出底部。
  /// 不用曲线动画: 拖动时要线性跟随手势。
  late final AnimationController _lyricAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  bool? _lastShowState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _lyricAnim.dispose();
    super.dispose();
  }

  void _closeLyric() {
    if (ref.read(miscUIProvider).showLyricPanel) {
      ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
    } else {
      _lyricAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final showLyricPanel =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));

    // provider 状态 → 滑入/滑出动画 (仅窄屏)。
    // 用 postFrame 执行动画, 避免 build 期间操作 AnimationController
    // 触发依赖变更断言 (_dependents.isEmpty)。
    if (_lastShowState != showLyricPanel) {
      _lastShowState = showLyricPanel;
      if (isNarrow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (showLyricPanel) {
            _lyricAnim.forward();
          } else {
            _lyricAnim.reverse();
          }
        });
      }
    }

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

    // 窄屏: 歌词面板从底部滑入, 拖动跟随手势, 松手按速度/位置决定开合
    final scheme = Theme.of(context).colorScheme;
    final panelHeight = MediaQuery.sizeOf(context).height;
    return Expanded(
      child: Stack(
        children: [
          const ListsView(),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: (details) {
              if (!showLyricPanel) return;
              _lyricAnim.stop();
              _lyricAnim.value = (_lyricAnim.value -
                      (details.primaryDelta ?? 0) / panelHeight)
                  .clamp(0.0, 1.0);
            },
            onVerticalDragEnd: (details) {
              if (!showLyricPanel) return;
              final v = details.primaryVelocity ?? 0;
              if (v > 300 || _lyricAnim.value < 0.35) {
                _closeLyric();
              } else {
                _lyricAnim.forward();
              }
            },
            child: AnimatedBuilder(
              animation: _lyricAnim,
              builder: (context, child) => Transform.translate(
                // 用屏幕高度平移 (面板比屏幕矮, FractionalTranslation 按
                // 自身高度平移会露出面板顶部)
                offset: Offset(
                    0, MediaQuery.sizeOf(context).height * (1 - _lyricAnim.value)),
                child: child,
              ),
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
