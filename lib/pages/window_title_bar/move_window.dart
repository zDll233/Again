import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MoveWindow extends StatelessWidget {
  const MoveWindow({
    super.key,
    required this.child,
    this.moveOnChildWidget = false,
  });
  final Widget child;
  final bool moveOnChildWidget;

  @override
  Widget build(BuildContext context) {
    // 非 Windows (Android 等) 无窗口拖动概念, 直接透传
    if (!Platform.isWindows) {
      return child;
    }
    if (moveOnChildWidget) {
      return DragToMoveArea(child: child);
    } else {
      return Stack(
        children: [
          Positioned.fill(child: DragToMoveArea(child: Container())),
          child,
        ],
      );
    }
  }
}
