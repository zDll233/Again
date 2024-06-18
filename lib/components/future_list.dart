import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FutureListView<T> extends StatelessWidget {
  const FutureListView({
    super.key,
    required this.future,
    required this.itemBuilder,
    this.emptyMessage = 'No items found',
    this.scrollController,
  });

  final Future<List<T>> future;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String emptyMessage;
  final ItemScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(emptyMessage));
        } else {
          return ScrollablePositionedList.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return itemBuilder(context, snapshot.data![index], index);
            },
            itemScrollController: scrollController,
          );
        }
      },
    );
  }
}
