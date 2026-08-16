import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 窄屏左右滑动切换面板 (PageView)。
/// 宽屏直接用 Row 并排; 窄屏 (如手机竖屏, 宽度不足以并排) 用 PageView
/// 左右滑动切换。面板自身已有标题 (作品/音轨/封面/歌词), 不再加 tab 条。
class PanelSwitcher extends ConsumerStatefulWidget {
  const PanelSwitcher({
    super.key,
    required this.panels,
    this.initialPage = 0,
    this.pageProvider,
  });

  final List<Widget> panels;
  final int initialPage;

  /// 外部跳页请求 (监听变化动画切页); 为 null 时不监听。
  final StateProvider<int>? pageProvider;

  @override
  ConsumerState<PanelSwitcher> createState() => _PanelSwitcherState();
}

class _PanelSwitcherState extends ConsumerState<PanelSwitcher> {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.pageProvider;
    if (provider != null) {
      ref.listen<int>(provider, (prev, next) {
        if (next != prev && next != (_controller.page?.round() ?? -1)) {
          _controller.animateToPage(
            next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
    return PageView(
      controller: _controller,
      // KeepAlive: 切页后页面 State 不销毁, 列表滚动位置不丢,
      // 也不会在切回时重建导致列表跳动/自动滚动
      children: [for (final panel in widget.panels) _KeepAlive(child: panel)],
    );
  }
}

/// 让 PageView 页面保持存活 (切出视口后 State 不销毁)。
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
