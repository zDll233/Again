import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceWorkPanel extends StatelessWidget {
  const VoiceWorkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return VoicePanel(
      title: 'VoiceWorks',
      listView: FutureVoiceWorkListView(),
      icon: const Icon(Icons.refresh),
      onLocateBtnPressed: c.databaseController.onUpdatePressed,
    );
  }
}

class FutureVoiceWorkListView extends StatelessWidget {
  FutureVoiceWorkListView({super.key});

  final Controller c = Get.find();

  Future<List> fetchItems() async {
    List titleList = c.databaseController.vkTitleList.toList();
    return titleList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => FutureListView(
          future: fetchItems(),
          itemBuilder: (context, title, index) {
            return Obx(() => ListTile(
                  title: Text(title),
                  onTap: () {
                    c.uiController.onVkSelected(index);
                  },
                  selected: c.uiController.selectedVkIdx.value == index,
                ));
          },
          scrollController: c.uiController.vkScrollController,
        ));
  }
}
