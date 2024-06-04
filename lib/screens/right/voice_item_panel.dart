import 'package:again/controller/audio_controller.dart';
import 'package:again/database/database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceItemPanel extends StatelessWidget {
  const VoiceItemPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = Get.find();

    return Column(
      children: [
        const SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('VoiceItems'),
                ElevatedButton(onPressed: null, child: Icon(Icons.location_searching))
              ],
            )),
        Expanded(
          child: Obx(() => FutureVoiceItemListView(
                selectedVkTitle: audioController.selectedVkTitle.value,
                playingViIdx: audioController.playingViIdx.value,
              )),
        ),
      ],
    );
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  final String selectedVkTitle;
  final int playingViIdx;

  FutureVoiceItemListView(
      {required this.selectedVkTitle, required this.playingViIdx, super.key});

  final AudioController audioController = Get.find();

  Future<List<TVoiceItemData>> fetchItems(String vkTitle) async {
    var viDataList =
        await database.selectSingleWorkVoiceItemsWithString(vkTitle);
    audioController.selectedViPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));
    return viDataList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TVoiceItemData>>(
      future: fetchItems(selectedVkTitle),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              bool isSelected = playingViIdx == index &&
                  audioController.playingVkIdx.value ==
                      audioController.selectedVkIdx.value;
              return ListTile(
                title: Text(
                  snapshot.data![index].title,
                ),
                onTap: () {
                  Source source =
                      DeviceFileSource(snapshot.data![index].filePath);
                  audioController.play(source);

                  audioController.playingViIdx.value = index;
                  audioController.playingVkIdx.value =
                      audioController.selectedVkIdx.value;
                  audioController.playingViPathList =
                      audioController.selectedViPathList;
                },
                selected: isSelected,
              );
            },
          );
        }
      },
    );
  }
}
