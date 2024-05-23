import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:again/database/database.dart';
import 'package:again/screens/player_widget.dart';

class SimpleAudioPlayer extends StatefulWidget {
  const SimpleAudioPlayer({super.key});

  @override
  State<SimpleAudioPlayer> createState() => _SimpleAudioPlayerState();
}

class _SimpleAudioPlayerState extends State<SimpleAudioPlayer> {
  late AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Create the audio player.
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);

    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(DeviceFileSource(await database
          .selectSingleWorkVoiceItemsWithString(
              '陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～')
          .then((List<TVoiceItemData> vd) => vd[1].filePath)));

      // await player.resume();
    });
  }

  @override
  void dispose() {
    // Release all sources and dispose the player.
    player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerWidget(player: player);
  }
}
