import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return VoicePanel(
      title: 'Filter',
      listView: FutureFilterListView(),
      icon: const Icon(Icons.remove),
      onIconBtnPressed: c.ui.onRemoveFilterPressed,
    );
  }
}

class FutureFilterListView extends StatelessWidget {
  FutureFilterListView({super.key});

  final Controller c = Get.find();

  Future<List> fetchcategoryItems() async {
    return c.ui.categories.toList();
  }

  Future<List> fetchCvItems() async {
    return c.ui.cvNames.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Obx(() => FutureListView(
                future: fetchcategoryItems(),
                itemBuilder: (context, category, index) {
                  return Obx(() => ListTile(
                        title: Text(category),
                        onTap: () {
                          c.ui.onCategorySelected(index);
                        },
                        selected: c.ui.selectedCategoryIdx.value == index,
                      ));
                },
              )),
        ),
        SizedBox(
          width: 150,
          child: Obx(() => FutureListView(
                future: fetchCvItems(),
                itemBuilder: (context, title, index) {
                  return Obx(() => ListTile(
                        title: Text(title),
                        onTap: () {
                          c.ui.onCvSelected(index);
                        },
                        selected: c.ui.selectedCvIdx.value == index,
                      ));
                },
                scrollController: c.ui.cvScrollController,
              )),
        )
      ],
    );
  }
}
