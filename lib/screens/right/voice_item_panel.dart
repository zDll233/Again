import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceItemPanel extends StatelessWidget {
  const VoiceItemPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return VoicePanel(
      title: 'VoiceItems',
      listView: FutureVoiceItemListView(),
      icon: const Icon(Icons.location_searching),
      onLocateBtnPressed: c.uiController.onLocateBtnPressed,
    );
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  FutureVoiceItemListView({super.key});

  final Controller c = Get.find();

  Future<List> fetchItems() async {
    List titleList = c.uiController.selectedViTitleList.toList();
    return titleList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FutureListView(
        future: fetchItems(),
        itemBuilder: (context, title, index) {
          return Obx(() => ListTile(
                title: Text(title),
                onTap: () {
                  c.uiController.onViSelected(index);
                },
                selected: c.audioController.playingViIdx.value == index &&
                    c.uiController.playingVkIdx.value ==
                        c.uiController.selectedVkIdx.value,
              ));
        },
      ),
    );
  }
}
