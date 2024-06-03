import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../database/database.dart';
import '../../controller/audio_controller.dart';

class VoiceItemPanel extends StatelessWidget {
  const VoiceItemPanel({super.key});

  @override
  Widget build(BuildContext context) {
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
        Expanded(child: FutureVoiceItemListView()),
      ],
    );
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  FutureVoiceItemListView({super.key});

  final AudioController audioController = Get.find();

  Future<List<TVoiceItemData>> fetchItems() async {
    return await database.selectSingleWorkVoiceItemsWithString(
        '陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TVoiceItemData>>(
      future: fetchItems(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].title),
                // onTap: c.setPlayablePath(snapshot.data![index].filePath),
                onTap: () {
                  Source source =
                      DeviceFileSource(snapshot.data![index].filePath);
                  audioController.play(source);
                },
              );
            },
          );
        }
      },
    );
  }
}
