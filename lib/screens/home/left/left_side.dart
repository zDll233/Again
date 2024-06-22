import 'package:again/screens/home/left/filter_panel.dart';
import 'package:flutter/material.dart';

import 'voice_work_panel.dart';

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});
  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width - 260;
    return Row(
      children: [
        const SizedBox(
          width: 250,
          child: FilterPanel(),
        ),
        const VerticalDivider(
          width: 5.0,
          color: Color(0x80B3B0F6),
        ),
        SizedBox(width: appWidth * 0.60, child: const VoiceWorkPanel()),
      ],
    );
  }
}
