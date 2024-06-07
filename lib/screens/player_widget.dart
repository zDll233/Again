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

  final _iconSize = 45.0;

  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    final appWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => SizedBox(
        height: 100, // 您可以根据需要调整这个高度
        child: Stack(
          children: [
            Positioned(
              top: 5,
              child: SizedBox(
                height: 50,
                width: appWidth,
                child: Slider(
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
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  c.position.value != Duration.zero
                      ? '${c.position.value.toString().split('.').first} /${c.duration.value.toString().split('.').first}'
                      : c.duration.value != Duration.zero
                          ? c.duration.value.toString().split('.').first
                          : '',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: const Key('prev_button'),
                      onPressed: c.playingViIdx >= 0 ? c.playPrev : null,
                      iconSize: _iconSize,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      key: const Key('play_pause_button'),
                      onPressed: c.playingViIdx >= 0
                          ? c.playerState.value == PlayerState.playing
                              ? c.pause
                              : c.resume
                          : null,
                      iconSize: _iconSize,
                      icon: c.playerState.value == PlayerState.playing
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      key: const Key('next_button'),
                      onPressed: c.playingViIdx >= 0 ? c.playNext : null,
                      iconSize: _iconSize,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
