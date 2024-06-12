import 'package:again/components/voice_panel.dart';
import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const VoicePanel(
      title: 'Filter',
      listView: Placeholder(),
      icon: Icon(Icons.remove),
      onLocateBtnPressed: null,
    );
  }
}