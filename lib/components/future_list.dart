import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FutureListView<T> extends StatelessWidget {
  final Future<List<T>> Function() fetchItems;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final ScrollController? scrollController;

  const FutureListView(
      {super.key,
      required this.fetchItems,
      required this.itemBuilder,
      this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FutureBuilder<List<T>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return itemBuilder(context, snapshot.data![index], index);
              },
              // controller: scrollController,
            );
          }
        },
      ),
    );
  }
}
