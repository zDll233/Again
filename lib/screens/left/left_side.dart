import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        child: Container(
            child: Column(
          children: [
            WindowTitleBarBox(child: MoveWindow()),
            Expanded(child: Container())
          ],
        )));
  }
}