import 'package:again/screens/window_title_bar/caption_buttons/window_caption_buttons.dart';
import 'package:again/screens/window_title_bar/move_window.dart';
import 'package:again/screens/window_title_bar/title_buttons/select_root_dir_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WindowTitleBar extends ConsumerStatefulWidget {
  const WindowTitleBar({
    super.key,
    this.title,
  });

  final Text? title;

  @override
  ConsumerState<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends ConsumerState<WindowTitleBar> {
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
