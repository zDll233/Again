import 'package:again/components/future_list.dart';
import 'package:again/controller/controller.dart';
import 'package:again/database/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                ElevatedButton(
                    onPressed: null, child: Icon(Icons.location_searching))
              ],
            )),
        Expanded(
          child: FutureVoiceItemListView(),
        ),
      ],
    );
  }
}

class FutureVoiceItemListView extends StatelessWidget {
  FutureVoiceItemListView({super.key});

  final Controller c = Get.find();

  Future<List<TVoiceItemData>> fetchItems() async {
    var viDataList = await database.selectSingleWorkVoiceItemsWithString(
        c.selectedVkTitle.value);
    c.selectedViPathList
      ..clear()
      ..addAll(viDataList.map((item) => item.filePath));
    return viDataList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FutureListView<TVoiceItemData>(
        future: fetchItems(),
        itemBuilder: (context, item, index) {
          return Obx(() => ListTile(
                title: Text(item.title),
                onTap: () {
                  c.onViSelected(index);
                },
                selected: c.playingViIdx.value == index &&
                    c.playingVkIdx.value ==
                        c.selectedVkIdx.value,
              ));
        },
        scrollController: c.vkScrollController,
      ),
    );
  }
}
