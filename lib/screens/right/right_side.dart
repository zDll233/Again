import 'package:flutter/material.dart';

import 'voice_item_panel.dart';

class RightSide extends StatelessWidget {
  const RightSide({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 300, child: VoiceItemPanel());
  }
}
