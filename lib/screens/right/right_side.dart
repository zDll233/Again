import 'package:again/controller/simple_audio_player.dart';
import 'package:again/screens/right/window_title_bar.dart';
import 'package:flutter/material.dart';

class RightSide extends StatelessWidget {
  const RightSide({super.key});
  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(children: [
        WindowTitleBar(),
        SimpleAudioPlayer(),
      ]),
    );
  }
}
