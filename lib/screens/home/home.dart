import 'package:again/controller/controller.dart';
import 'package:again/screens/home/left/left_side.dart';
import 'package:again/screens/player/lrc_panel.dart';
import 'package:again/screens/home/right/right_side.dart';
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
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: c.ui.showLrcPanel.value ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Offstage(
                  offstage: c.ui.showLrcPanel.value,
                  child: const ListView(),
                ),
              ),
              c.audio.playingViIdx.value >= 0
                  ? AnimatedOpacity(
                      opacity: c.ui.showLrcPanel.value ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Offstage(
                        offstage: !c.ui.showLrcPanel.value,
                        child: LyricPanel(),
                      ),
                    )
                  : Container(),
            ],
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
