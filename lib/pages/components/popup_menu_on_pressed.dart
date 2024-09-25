import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showPopupMenuOnPressed(
  BuildContext buttonContext,
  WidgetRef ref,
  List<PopupMenuEntry<String>> items,
  void Function(WidgetRef, String) onPopMenuSelected,
) {
  final RenderBox button = buttonContext.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

  // 获取按钮的位置和大小
  final Offset buttonOffset =
      button.localToGlobal(Offset.zero, ancestor: overlay);
  final Size buttonSize = button.size;

  final screenSize = MediaQuery.of(buttonContext).size;
  double left = buttonOffset.dx + buttonSize.width;
  double top = buttonOffset.dy;

  showMenu<String>(
    context: buttonContext,
    position: RelativeRect.fromLTRB(
      left,
      top,
      screenSize.width - left,
      screenSize.height - top,
    ),
    items: items,
  ).then((selectedValue) {
    if (selectedValue != null) {
      onPopMenuSelected(ref, selectedValue);
    }
  });
}
