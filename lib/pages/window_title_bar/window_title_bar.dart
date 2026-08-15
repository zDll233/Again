import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/pages/window_title_bar/caption_buttons/window_caption_buttons.dart';
import 'package:again/pages/window_title_bar/move_window.dart';
import 'package:again/pages/window_title_bar/tool_buttons/filter_toggle_btn.dart';
import 'package:again/pages/window_title_bar/tool_buttons/refresh_btn.dart';
import 'package:again/pages/window_title_bar/tool_buttons/settings_btn.dart';
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
              const FilterToggleBtn(buttonHeight: 40),
              Expanded(child: Container()),
              const RefreshBtn(buttonHeight: 40),
              const SettingsBtn(buttonHeight: 40),
              // 最小化/最大化/关闭按钮: Windows 专属
              if (Platform.isWindows)
                const CaptionButtons(buttonHeight: 40),
            ],
          ),
        ),
      ),
    );
  }
}
