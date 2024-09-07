import 'dart:io';
import 'package:again/controllers/controller.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final buttonColors = WindowButtonColors(
  iconNormal: const Color.fromRGBO(255, 255, 255, 0.5),
  mouseOver: const Color.fromRGBO(255, 255, 255, 0.1),
  mouseDown: const Color.fromRGBO(255, 255, 255, 0.2),
  iconMouseOver: const Color.fromRGBO(255, 255, 255, 1.0),
  iconMouseDown: const Color.fromRGBO(255, 255, 255, 1.0),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color.fromRGBO(211, 47, 47, 0.5),
  mouseDown: const Color.fromRGBO(183, 28, 28, 0.5),
  iconNormal: const Color.fromRGBO(255, 255, 255, 0.5),
  iconMouseOver: const Color.fromRGBO(255, 255, 255, 1.0),
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return Row(
      children: [
        IconButton(
            onPressed: c.db.selectAndSaveRootDirectory,
            icon: const Icon(
              Icons.folder_open,
              size: 20,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            )),
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () async {
            await c.saveHistory();
            appWindow.close();
          },
        ),
      ],
    );
  }
}

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          )
        : Container();
  }
}
