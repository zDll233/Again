import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:again/controller/controller.dart';

class PlayerWidget extends StatelessWidget {
  final AudioPlayer player;

  const PlayerWidget({
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Obx(() => Slider(
              onChanged: (value) {
                final duration = c.duration.value;
                if (duration == Duration.zero) {
                  return;
                }
                final position = value * duration.inMilliseconds;
                player.seek(Duration(milliseconds: position.round()));
              },
              value: (c.position.value != Duration.zero &&
                      c.duration.value != Duration.zero &&
                      c.position.value.inMilliseconds > 0 &&
                      c.position.value.inMilliseconds <
                          c.duration.value.inMilliseconds)
                  ? c.position.value.inMilliseconds /
                      c.duration.value.inMilliseconds
                  : 0.0,
            )),
        Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  c.position.value != Duration.zero
                      ? '${c.position.value.toString().split('.').first} / ${c.duration.value.toString().split('.').first}'
                      : c.duration.value != Duration.zero
                          ? c.duration.value
                              .toString()
                              .split('.')
                              .first
                          : '',
                  style: const TextStyle(fontSize: 16.0),
                ),
                IconButton(
                  key: const Key('prev_button'),
                  onPressed: c.playPrev,
                  iconSize: 48.0,
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  key: const Key('play_pause_button'),
                  onPressed:
                      c.playerState.value == PlayerState.playing
                          ? c.pause
                          : c.resume,
                  iconSize: 48.0,
                  icon: c.playerState.value == PlayerState.playing
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow),
                ),
                IconButton(
                  key: const Key('next_button'),
                  onPressed: c.playNext,
                  iconSize: 48.0,
                  icon: const Icon(Icons.skip_next),
                ),
                // IconButton(
                //   key: const Key('stop_button'),
                //   onPressed: c.playerState.value ==
                //               PlayerState.playing ||
                //           c.playerState.value ==
                //               PlayerState.paused
                //       ? c.stop
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
