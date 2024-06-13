import 'dart:io';
import 'package:again/controller/controller.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final buttonColors = WindowButtonColors(
  iconNormal: const Color.fromRGBO(255, 255, 255, 0.5), // 半透明白色图标
  mouseOver: const Color.fromRGBO(255, 255, 255, 0.1), // 鼠标悬停时的按钮颜色，透明度 10%
  mouseDown: const Color.fromRGBO(255, 255, 255, 0.2), // 鼠标按下时的按钮颜色，透明度 20%
  iconMouseOver: const Color.fromRGBO(255, 255, 255, 1.0), // 鼠标悬停时的图标颜色，纯白色
  iconMouseDown: const Color.fromRGBO(255, 255, 255, 1.0), // 鼠标按下时的图标颜色，纯白色
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color.fromRGBO(211, 47, 47, 0.5), // 关闭按钮鼠标悬停时的颜色，透明度 50%
  mouseDown: const Color.fromRGBO(183, 28, 28, 0.5), // 关闭按钮鼠标按下时的颜色，透明度 50%
  iconNormal: const Color.fromRGBO(255, 255, 255, 0.5), // 半透明白色图标
  iconMouseOver: const Color.fromRGBO(255, 255, 255, 1.0), // 鼠标悬停时的图标颜色，纯白色
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return Row(
      children: [
        IconButton(
            onPressed: c.database.selectDirectory,
            icon: const Icon(
              Icons.folder_open,
              size: 20,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            )),
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
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
