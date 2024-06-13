import 'package:again/screens/left/filter_panel.dart';
import 'package:flutter/material.dart';

import 'voice_work_panel.dart';

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 300,
          child: FilterPanel(),
        ),
        VerticalDivider(
          width: 5.0,
          color: Color(0x80B3B0F6),
        ),
        SizedBox(width: 400, child: VoiceWorkPanel()),
      ],
    );
  }
}
