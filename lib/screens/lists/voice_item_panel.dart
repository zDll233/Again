import 'dart:async';

import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceItemPanel extends StatelessWidget {
  const VoiceItemPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return Obx(() => VoicePanel(
          title: 'VoiceItems(${c.ui.selectedViList.length})',
          listView: FutureVoiceItemListView(),
          icon: const Icon(Icons.location_searching),
          onIconBtnPressed: c.ui.onLocateBtnPressed,
          onTextBtnPressed: c.ui.revealInExplorerView,
        ));
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  FutureVoiceItemListView({super.key});

  final Controller c = Get.find();

  Future<List> fetchItems() async {
    c.ui.viCompleter = Completer();
    return c.ui.selectedViList.toList();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.ui.viCompleter.complete();
    });
    return Obx(
      () => FutureListView(
        future: fetchItems(),
        itemBuilder: (context, vi, index) {
          return Obx(() => ListTile(
                title: Text(vi.title),
                onTap: () => c.ui.onViSelected(index),
                selected: c.ui.isCurrentViIdxPlaying(index),
              ));
        },
        itemScrollController: c.ui.viScrollController,
      ),
    );
  }
}
