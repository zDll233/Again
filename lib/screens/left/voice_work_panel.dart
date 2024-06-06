import 'package:again/components/future_list.dart';
import 'package:again/controller/audio_controller.dart';
import 'package:again/database/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceWorkPanel extends StatelessWidget {
  const VoiceWorkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = Get.find();

    return Column(
      children: [
        SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('VoiceItems'),
                ElevatedButton(
                    onPressed: () {
                      audioController.onLocateBtnPressed();
                    },
                    child: const Icon(Icons.location_searching))
              ],
            )),
        Expanded(
          child: FutureVoiceWorkListView(),
        ),
      ],
    );
  }
}

class FutureVoiceWorkListView extends StatelessWidget {
  FutureVoiceWorkListView({super.key});

  final AudioController audioController = Get.find();

  Future<List<TVoiceWorkData>> fetchItems() async {
    var vkDataList = await database.selectAllVoiceWorks;
    audioController.vkTitleList
      ..clear()
      ..addAll(vkDataList.map((item) => item.title));
    return vkDataList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureListView<TVoiceWorkData>(
      future: fetchItems(),
      itemBuilder: (context, item, index) {
        return Obx(() => ListTile(
              title: Text(item.title),
              onTap: () {
                audioController.onVkSelected(index);
              },
              selected: audioController.selectedVkIdx.value == index,
            ));
      },
      scrollController: audioController.vkScrollController,
    );
  }
}
