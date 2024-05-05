import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: 32.0,
            color: Colors.transparent,
            child: MoveWindow(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  MinimizeWindowButton(
                    colors: WindowButtonColors(
                      iconNormal:  Colors.white,
                      iconMouseDown:  Colors.white,
                      iconMouseOver:  Colors.white,
                      normal: Colors.transparent,
                      mouseOver:  Colors.white.withOpacity(0.04),
                      mouseDown:  Colors.white.withOpacity(0.08),
                    ),
                  ),
                  MaximizeWindowButton(
                    colors: WindowButtonColors(
                      iconNormal:  Colors.white,
                      iconMouseDown:  Colors.white,
                      iconMouseOver:  Colors.white,
                      normal: Colors.transparent,
                      mouseOver:  Colors.white.withOpacity(0.04),
                      mouseDown:  Colors.white.withOpacity(0.08),
                    ),
                  ),
                  CloseWindowButton(
                    onPressed: () {
                      appWindow.close();
                    },
                    colors: WindowButtonColors(
                      iconNormal:  Colors.white,
                      iconMouseDown:  Colors.white,
                      iconMouseOver:  Colors.white,
                      normal: Colors.transparent,
                      mouseOver:  Colors.white.withOpacity(0.04),
                      mouseDown:  Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
