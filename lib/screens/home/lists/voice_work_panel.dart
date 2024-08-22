import 'dart:async';

import 'package:again/components/future_list.dart';
import 'package:again/components/vk_menu_btn.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controllers/controller.dart';
import 'package:again/controllers/u_i_controller.dart';
import 'package:again/components/image_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceWorkPanel extends StatelessWidget {
  const VoiceWorkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return Obx(() => VoicePanel(
          title:
              'VoiceWorks(${c.ui.selectedVkList.length}): ${c.ui.sortOrder.value == SortOrder.byTitle ? 'title' : 'time'}',
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
    return c.ui.selectedVkList.toList();
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
                  trailing: VkMenuBtn(voiceWork: vk, selectedIndex: index),
                  onTap: () => c.ui.onVkSelected(index),
                  selected: c.ui.selectedVkIdx.value == index,
                  contentPadding: const EdgeInsets.only(
                      top: 5.0, bottom: 5.0, left: 20.0, right: 10.0),
                  horizontalTitleGap: 0.0,
                ));
          },
          itemScrollController: c.ui.vkScrollController,
        ));
  }
}
