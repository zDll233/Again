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
                ElevatedButton(onPressed: null, child: Icon(Icons.refresh))
              ],
            )),
        Expanded(
          child: Obx(() =>
              FutureVoiceItemListView(vkTitle: audioController.vkTitle.value)),
        ),
      ],
    );
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  final String vkTitle;

  FutureVoiceItemListView({required this.vkTitle, super.key});

  final AudioController audioController = Get.find();

  Future<List<TVoiceItemData>> fetchItems(String vkTitle) async {
    var viDataList =
        await database.selectSingleWorkVoiceItemsWithString(vkTitle);
    audioController.viPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));
    return viDataList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TVoiceItemData>>(
      future: fetchItems(vkTitle),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].title),
                onTap: () {
                  Source source =
                      DeviceFileSource(snapshot.data![index].filePath);
                  audioController.play(source);
                  audioController.currentIdx.value = index;
                },
              );
            },
          );
        }
      },
    );
  }
}
