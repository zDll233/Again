import 'dart:async';

import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controller/controller.dart';
import 'package:again/controller/u_i_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceWorkPanel extends StatelessWidget {
  const VoiceWorkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return Obx(() => VoicePanel(
          title:
              'VoiceWorks(${c.ui.vkTitleList.length}): ${c.ui.sortOrder.value == SortOrder.byTitle ? 'title' : 'time'}',
          listView: FutureVoiceWorkListView(),
          icon: const Icon(Icons.refresh),
          onIconBtnPressed: c.db.onUpdatePressed,
          onTextBtnPressed: c.ui.onSortOrderPressed,
        ));
  }
}

class FutureVoiceWorkListView extends StatelessWidget {
  FutureVoiceWorkListView({super.key});

  final Controller c = Get.find();

  Future<List> fetchItems() async {
    return c.ui.vkTitleList.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureListView(
          future: fetchItems(),
          itemBuilder: (context, title, index) {
            return Obx(() => ListTile(
                  title: Text(title),
                  onTap: () {
                    c.ui.onVkSelected(index);
                  },
                  selected: c.ui.selectedVkIdx.value == index,
                ));
          },
          itemScrollController: c.ui.vkScrollController,
        ));
  }
}
