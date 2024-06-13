import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return VoicePanel(
      title: 'Filter',
      listView: FutureFilterListView(),
      icon: const Icon(Icons.remove),
      onLocateBtnPressed: null,
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
          width: 120,
          child: Obx(() => FutureListView(
                future: fetchcategoryItems(),
                itemBuilder: (context, title, index) {
                  return Obx(() => ListTile(
                        title: Text(title),
                        onTap: () {
                          c.ui.onCvSelected(index);
                        },
                        selected: c.ui.selectedCvIdx.value == index,
                      ));
                },
                // scrollController: c.ui.vkScrollController,
              )),
        ),
        SizedBox(
          width: 180,
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
                // scrollController: c.ui.vkScrollController,
              )),
        )
      ],
    );
  }
}
