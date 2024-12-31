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
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: MoveWindow(
        child: SizedBox(
          height: TITLEBAR_HEIGHT,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Container()),
              const SelectRootDirBtn(buttonHeight: 40),
              const CaptionButtons(buttonHeight: 40),
            ],
          ),
        ),
      ),
    );
  }
}
