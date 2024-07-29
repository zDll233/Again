import 'dart:async';
import 'dart:io';

import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controllers/controller.dart';
import 'package:again/controllers/u_i_controller.dart';
import 'package:again/models/voice_work.dart';
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

  Widget getVkCover(String path) {
    var coverFile = File(path);
    return _buildImage((coverFile.existsSync()
        ? FileImage(coverFile)
        : const AssetImage('assets/images/nocover.jpg')) as ImageProvider);
  }

  Widget _buildImage(ImageProvider imageProvider) {
    double size = 60.0;
    return Image(
      image: imageProvider,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureListView(
          future: fetchItems(),
          itemBuilder: (context, vkList, index) {
            return Obx(() => ListTile(
                  leading: getVkCover(vkList.coverPath),
                  title: Text(vkList.title),
                  onTap: () {
                    c.ui.onVkSelected(index);
                  },
                  selected: c.ui.selectedVkIdx.value == index,
                  minVerticalPadding: 15.0,
                ));
          },
          itemScrollController: c.ui.vkScrollController,
        ));
  }
}
