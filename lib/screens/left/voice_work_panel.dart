import 'package:flutter/material.dart';

import '../../database/database.dart';

class VoiceWorkPanel extends StatelessWidget {
  const VoiceWorkPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
            height: 50.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('VoiceWorks'),
                ElevatedButton(onPressed: null, child: Icon(Icons.refresh))
              ],
            )),
        Expanded(child: FutureListView()),
      ],
    );
  }
}

class FutureListView extends StatelessWidget {
  const FutureListView({super.key});

  Future<List<TVoiceWorkData>> fetchItems() async {
    return database.selectAllVoiceWorks;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TVoiceWorkData>>(
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