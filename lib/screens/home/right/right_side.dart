import 'package:flutter/material.dart';

import 'voice_item_panel.dart';

class RightSide extends StatelessWidget {
  const RightSide({super.key});
  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width - 260;
    return SizedBox(width: appWidth * 0.40, child: const VoiceItemPanel());
  }
}
