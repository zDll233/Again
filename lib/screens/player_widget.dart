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
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 10.0),
                  ),
                  child: Slider(
                    onChanged: (value) {
                      final duration = c.audioController.duration.value;
                      if (duration == Duration.zero) {
                        return;
                      }
                      final position = value * duration.inMilliseconds;
                      player.seek(Duration(milliseconds: position.round()));
                    },
                    value: (c.audioController.position.value != Duration.zero &&
                            c.audioController.duration.value != Duration.zero &&
                            c.audioController.position.value.inMilliseconds > 0 &&
                            c.audioController.position.value.inMilliseconds <
                                c.audioController.duration.value.inMilliseconds)
                        ? c.audioController.position.value.inMilliseconds /
                            c.audioController.duration.value.inMilliseconds
                        : 0.0,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 15,
              child: SizedBox(
                width: 150,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: c.audioController.onMutePressed,
                        icon: c.audioController.volume.value == 0
                            ? const Icon(Icons.volume_off)
                            : const Icon(Icons.volume_up)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 1.0,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 1.0),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 10.0),
                        ),
                        child: Slider(
                          value: c.audioController.volume.value,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (double value) {
                            c.audioController.setVolume(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  c.audioController.position.value != Duration.zero
                      ? '${c.audioController.position.value.toString().split('.').first} /${c.audioController.duration.value.toString().split('.').first}'
                      : c.audioController.duration.value != Duration.zero
                          ? c.audioController.duration.value.toString().split('.').first
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
                      onPressed: c.audioController.playingViIdx >= 0 ? c.audioController.playPrev : null,
                      iconSize: _iconSize,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      key: const Key('play_pause_button'),
                      onPressed: c.audioController.playingViIdx >= 0
                          ? c.audioController.playerState.value == PlayerState.playing
                              ? c.audioController.pause
                              : c.audioController.resume
                          : null,
                      iconSize: _iconSize,
                      icon: c.audioController.playerState.value == PlayerState.playing
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                    ),
                    IconButton(
                      key: const Key('next_button'),
                      onPressed: c.audioController.playingViIdx >= 0 ? c.audioController.playNext : null,
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
