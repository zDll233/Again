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
    return Obx(() => VoicePanel(
          title: 'VoiceItems(${c.ui.selectedViTitleList.length})',
          listView: FutureVoiceItemListView(),
          icon: const Icon(Icons.location_searching),
          onIconBtnPressed: c.ui.onLocateBtnPressed,
          onTextBtnPressed: c.ui.onOpenSelectedVkFolder,
        ));
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  FutureVoiceItemListView({super.key});

  final Controller c = Get.find();

  Future<List> fetchItems() async {
    return c.ui.selectedViTitleList.toList();
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
                  c.ui.onViSelected(index);
                },
                selected: c.ui.isCurrentViIdxPlaying(index),
              ));
        },
        scrollController: c.ui.viScrollController,
      ),
    );
  }
}
