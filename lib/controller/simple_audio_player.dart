import 'package:again/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:again/screens/player_widget.dart';

class SimpleAudioPlayer extends StatefulWidget {
  const SimpleAudioPlayer({super.key});

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  @override
  Widget build(BuildContext context) {
    final AudioController audioController = Get.find();
    return PlayerWidget(player: audioController.player);
  }
}
