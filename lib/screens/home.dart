import 'package:again/controller/controller.dart';
import 'package:again/screens/left/left_side.dart';
import 'package:again/screens/lrc_panel.dart';
import 'package:again/screens/right/right_side.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  Home({
    super.key,
  });

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return _viewSwitch();
  }

  Widget _viewSwitch() {
    return Obx(() => Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: c.ui.showLrcPanel.value ? LyricPanel() : const ListView(),
          ),
        ));
  }
}

class ListView extends StatelessWidget {
  const ListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LeftSide(),
        VerticalDivider(
          width: 5.0,
          color: Color(0x80B3B0F6),
        ),
        RightSide()
      ],
    );
  }
}
