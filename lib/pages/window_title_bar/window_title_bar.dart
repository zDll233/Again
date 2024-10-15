import 'package:again/common/const.dart';
import 'package:again/pages/window_title_bar/caption_buttons/window_caption_buttons.dart';
import 'package:again/pages/window_title_bar/move_window.dart';
import 'package:again/pages/window_title_bar/tool_buttons/select_root_dir_btn.dart';
import 'package:flutter/material.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    this.title,
  });

  final Text? title;

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.transparent),
      child: SizedBox(
        height: titleBarHeight,
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
            SelectRootDirBtn(),
            CaptionButtons(buttonHeight: 40),
          ],
        ),
      ),
    );
  }
}
