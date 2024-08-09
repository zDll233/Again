import 'package:again/screens/home/lists/filter_panel.dart';
import 'package:again/screens/home/lists/voice_work_panel.dart';
import 'package:again/screens/home/lists/voice_item_panel.dart';
import 'package:flutter/material.dart';

class ListsView extends StatelessWidget {
  const ListsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double dividerWidth = 5.0;
    const Color dividerColor = Color(0x80B3B0F6);

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: FilterPanel(),
        ),
        VerticalDivider(
          width: dividerWidth,
          color: dividerColor,
        ),
        Flexible(
          flex: 16,
          child: VoiceWorkPanel(),
        ),
        VerticalDivider(
          width: dividerWidth,
          color: dividerColor,
        ),
        Flexible(
          flex: 10,
            child: VoiceItemPanel(),
        ),
      ],
    );
  }
}
