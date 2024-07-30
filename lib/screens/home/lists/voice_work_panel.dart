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

  final Controller c = Get.find();

  Future<List> fetchItems() async {
    List<VoiceWork> vkList = [];
    for (int idx = 0; idx < c.ui.vkTitleList.length; idx++) {
      vkList.add(VoiceWork(
          title: c.ui.vkTitleList[idx], coverPath: c.ui.vkCoverPathList[idx]));
    }
    return vkList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureListView(
          future: fetchItems(),
          itemBuilder: (context, vk, index) {
            return Obx(() => Padding(
              padding: const EdgeInsets.only(top: 5.0,bottom: 5.0),
              child: ListTile(
                    leading: ImageThumbnail(imagePath: vk.coverPath),
                    title: Text(vk.title),
                    onTap: () {
                      c.ui.onVkSelected(index);
                    },
                    selected: c.ui.selectedVkIdx.value == index,
                    // minVerticalPadding: 15.0,
                  ),
            ));
          },
          itemScrollController: c.ui.vkScrollController,
        ));
  }
}
