import 'package:again/pages/lists/filter_panel/filter_panel.dart';
import 'package:again/pages/lists/voice_work_panel/voice_work_panel.dart';
import 'package:again/pages/lists/voice_item_panel/voice_item_panel.dart';
import 'package:flutter/material.dart';

const _verticalDivider = VerticalDivider(
  width: 5.0,
  color: Color(0x80B3B0F6),
);

class ListsView extends StatelessWidget {
  const ListsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 250, child: FilterPanel()),
        _verticalDivider,
        Flexible(flex: 16, child: VoiceWorkPanel()),
        _verticalDivider,
        Flexible(flex: 10, child: VoiceItemPanel()),
      ],
    );
  }
}
