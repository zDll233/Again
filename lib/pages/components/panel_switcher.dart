import 'package:flutter/material.dart';

/// 窄屏左右滑动切换面板 (PageView)。
/// 宽屏直接用 Row 并排; 窄屏 (如手机竖屏, 宽度不足以并排) 用 PageView
/// 左右滑动切换。面板自身已有标题 (作品/音轨/封面/歌词), 不再加 tab 条。
class PanelSwitcher extends StatefulWidget {
  const PanelSwitcher({
    super.key,
    required this.panels,
    this.initialPage = 0,
  });

  final List<Widget> panels;
  final int initialPage;

  @override
  State<PanelSwitcher> createState() => _PanelSwitcherState();
}

class _PanelSwitcherState extends State<PanelSwitcher> {
  late final PageController _controller =
      PageController(initialPage: widget.initialPage);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: widget.panels,
    );
  }
}
