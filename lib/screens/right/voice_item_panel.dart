import 'package:flutter/material.dart';

import '../../database/database.dart';

class VoiceItemPanel extends StatelessWidget {
  const VoiceItemPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
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
  const FutureVoiceItemListView({super.key});

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
          // 如果数据为空，显示提示信息
          return const Center(child: Text('No items found'));
        } else {
          // 数据已返回，构建ListView
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].title),
              );
            },
          );
        }
      },
    );
  }
}
