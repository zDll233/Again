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
        const SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('VoiceItems'),
                ElevatedButton(
                    onPressed: null, child: Icon(Icons.location_searching))
              ],
            )),
        Expanded(
          child: Obx(() => FutureVoiceWorkListView(
              vkIdx: audioController.selectedVkIdx.value)),
        ),
      ],
    );
  }
}

class FutureVoiceWorkListView extends StatelessWidget {
  final int vkIdx;

  FutureVoiceWorkListView({required this.vkIdx, super.key});

  final AudioController audioController = Get.find();

  Future<List<TVoiceWorkData>> fetchItems() async {
    return database.selectAllVoiceWorks;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TVoiceWorkData>>(
      future: fetchItems(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              bool isSelected = vkIdx == index;
              return ListTile(
                title: Text(snapshot.data![index].title),
                onTap: () {
                  audioController
                      .setSelectedVkTitle(snapshot.data![index].title);
                  audioController.selectedVkIdx.value = index;
                },
                selected: isSelected ? true : false,
              );
            },
          );
        }
      },
    );
  }
}
