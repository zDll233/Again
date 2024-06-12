import 'package:again/components/voice_panel.dart';
import 'package:again/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return const VoicePanel(
      title: 'Filter',
      listView: Placeholder(),
      icon: Icon(Icons.remove),
      onLocateBtnPressed: null,
    );
  }
}