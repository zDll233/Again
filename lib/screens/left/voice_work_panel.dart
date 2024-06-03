import 'package:again/controller/audio_controller.dart';
import 'package:again/database/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceWorkPanel extends StatelessWidget {
  const VoiceWorkPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('VoiceWorks'),
                ElevatedButton(onPressed: null, child: Icon(Icons.refresh))
              ],
            )),
        Expanded(child: FutureVoiceWorkListView()),
      ],
    );
  }
}

class FutureVoiceWorkListView extends StatelessWidget {
  FutureVoiceWorkListView({super.key});
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
              return ListTile(
                title: Text(snapshot.data![index].title),
                onTap: () {
                  audioController.setVKTitle(snapshot.data![index].title);
                },
              );
            },
          );
        }
      },
    );
  }
}
