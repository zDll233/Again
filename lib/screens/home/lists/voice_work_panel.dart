import 'dart:async';

import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controllers/controller.dart';
import 'package:again/controllers/u_i_controller.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/utils/image_thumbnail.dart';
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

  final ui = Get.find<UIController>();

  Future<List> fetchItems() async {
    List<VoiceWork> vkList = [];
    for (int idx = 0; idx < ui.vkTitleList.length; idx++) {
      vkList.add(VoiceWork(
          title: ui.vkTitleList[idx], coverPath: ui.vkCoverPathList[idx]));
    }
    return vkList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureListView(
          future: fetchItems(),
          itemBuilder: (context, vk, index) {
            return Obx(() => ListTile(
                  leading: ImageThumbnail(imagePath: vk.coverPath),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                    child: Text(vk.title),
                  ),
                  trailing: vkMenu(context, vk.title),
                  onTap: () => ui.onVkSelected(index),
                  selected: ui.selectedVkIdx.value == index,
                  contentPadding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
                  horizontalTitleGap: 0.0,
                ));
          },
          itemScrollController: ui.vkScrollController,
        ));
  }

  void selectCv(String cvName) {
    final cvIndex = ui.cvNames.indexOf(cvName);
    ui.onCvSelected(cvIndex);
    ui.scrollToIndex(ui.cvScrollController, cvIndex);
  }

  Widget vkMenu(BuildContext context, String vkTitle) {
    List<String> cvList = vkTitle.split('-')[0].split('&');
    return TooltipVisibility(
      visible: false,
      child: PopupMenuButton<String>(
        onSelected: (String value) => selectCv(value),
        itemBuilder: (BuildContext context) {
          return cvList
              .map((cvName) =>
                  PopupMenuItem<String>(value: cvName, child: Text(cvName)))
              .toList();
        },
      ),
    );
  }
}
