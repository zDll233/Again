import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:again/controller/audio_controller.dart';

class PlayerWidget extends StatelessWidget {
  final AudioPlayer player;

  const PlayerWidget({
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AudioController audioController = Get.find();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Obx(() => Slider(
              onChanged: (value) {
                final duration = audioController.duration.value;
                if (duration == Duration.zero) {
                  return;
                }
                final position = value * duration.inMilliseconds;
                player.seek(Duration(milliseconds: position.round()));
              },
              value: (audioController.position.value != Duration.zero &&
                      audioController.duration.value != Duration.zero &&
                      audioController.position.value.inMilliseconds > 0 &&
                      audioController.position.value.inMilliseconds <
                          audioController.duration.value.inMilliseconds)
                  ? audioController.position.value.inMilliseconds /
                      audioController.duration.value.inMilliseconds
                  : 0.0,
            )),
        Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  audioController.position.value != Duration.zero
                      ? '${audioController.position.value.toString().split('.').first} / ${audioController.duration.value.toString().split('.').first}'
                      : audioController.duration.value != Duration.zero
                          ? audioController.duration.value
                              .toString()
                              .split('.')
                              .first
                          : '',
                  style: const TextStyle(fontSize: 16.0),
                ),
                IconButton(
                  key: const Key('prev_button'),
                  onPressed: audioController.playPrev,
                  iconSize: 48.0,
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  key: const Key('play_pause_button'),
                  onPressed:
                      audioController.playerState.value == PlayerState.playing
                          ? audioController.pause
                          : audioController.resume,
                  iconSize: 48.0,
                  icon: audioController.playerState.value == PlayerState.playing
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                ),
                IconButton(
                  key: const Key('next_button'),
                  onPressed: audioController.playNext,
                  iconSize: 48.0,
                  icon: const Icon(Icons.skip_next),
                ),
                // IconButton(
                //   key: const Key('stop_button'),
                //   onPressed: audioController.playerState.value ==
                //               PlayerState.playing ||
                //           audioController.playerState.value ==
                //               PlayerState.paused
                //       ? audioController.stop
                //       : null,
                //   iconSize: 48.0,
                //   icon: const Icon(Icons.stop),
                //   color: Theme.of(context).primaryColor,
                // ),
              ],
            )),
      ],
    );
  }
}
