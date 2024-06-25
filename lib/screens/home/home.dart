import 'package:again/controller/controller.dart';
import 'package:again/screens/home/lists/lists_view.dart';
import 'package:again/screens/player/lrc_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  Home({
    super.key,
  });

  final Controller c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Expanded(
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: c.ui.showLrcPanel.value ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Offstage(
                  offstage: c.ui.showLrcPanel.value,
                  child: const ListsView(),
                ),
              ),
              AnimatedOpacity(
                opacity: c.ui.showLrcPanel.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Offstage(
                  offstage: !c.ui.showLrcPanel.value,
                  child: LyricPanel(),
                ),
              )
            ],
          ),
        ));
  }
}
