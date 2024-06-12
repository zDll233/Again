import 'package:again/screens/left/filter_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'voice_work_panel.dart';

class LeftSide extends StatelessWidget {
  const LeftSide({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 200,child: FilterPanel(),),
        SizedBox(width: 300, child: VoiceWorkPanel()),
      ],
    );
  }
}
