import 'package:again/controller/audio_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:again/controller/controller.dart';

class PlayerWidget extends StatelessWidget {
  final AudioPlayer player;
  static const double _iconSize = 45.0;
  final Controller c = Get.find();

  PlayerWidget({
    required this.player,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => SizedBox(
        height: 100, // Adjust this height as needed
        child: Stack(
          children: [
            _buildProgressBar(context, appWidth),
            _buildVolumeControl(context),
            _buildTimeDisplay(),
            _buildPlaybackControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double appWidth) {
    return Positioned(
      top: 5,
      child: SizedBox(
        height: 50,
        width: appWidth,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 1.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
          ),
          child: Slider(
            onChanged: (value) {
              final duration = c.audio.duration.value;
              if (duration != Duration.zero) {
                final position = value * duration.inMilliseconds;
                player.seek(Duration(milliseconds: position.round()));
              }
            },
            value: _getProgressBarValue(),
          ),
        ),
      ),
    );
  }

  double _getProgressBarValue() {
    if (c.audio.position.value != Duration.zero &&
        c.audio.duration.value != Duration.zero &&
        c.audio.position.value.inMilliseconds > 0 &&
        c.audio.position.value.inMilliseconds <
            c.audio.duration.value.inMilliseconds) {
      return c.audio.position.value.inMilliseconds /
          c.audio.duration.value.inMilliseconds;
    } else {
      return 0.0;
    }
  }

  Widget _buildVolumeControl(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: 10,
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            IconButton(
              onPressed: c.audio.onMutePressed,
              icon: c.audio.volume.value == 0
                  ? const Icon(Icons.volume_off)
                  : const Icon(Icons.volume_up),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1.0,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 1.0),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 10.0),
                ),
                child: Slider(
                  value: c.audio.volume.value,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (double value) {
                    c.audio.setVolume(value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          _getTimeDisplayText(),
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  String _getTimeDisplayText() {
    if (c.audio.position.value != Duration.zero) {
      return '${c.audio.position.value.toString().split('.').first} / ${c.audio.duration.value.toString().split('.').first}';
    } else if (c.audio.duration.value != Duration.zero) {
      return c.audio.duration.value.toString().split('.').first;
    } else {
      return '';
    }
  }

  Widget _buildPlaybackControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPrevButton(),
            _buildPlayPauseButton(),
            _buildNextButton(),
            _buildLoopModeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrevButton() {
    return IconButton(
      key: const Key('prev_button'),
      onPressed: c.audio.playingViIdx >= 0 ? c.audio.playPrev : null,
      iconSize: _iconSize,
      icon: const Icon(Icons.skip_previous),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      key: const Key('play_pause_button'),
      onPressed: c.audio.playingViIdx >= 0
          ? c.audio.playerState.value == PlayerState.playing
              ? c.audio.pause
              : c.audio.resume
          : null,
      iconSize: _iconSize,
      icon: c.audio.playerState.value == PlayerState.playing
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow),
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      key: const Key('next_button'),
      onPressed: c.audio.playingViIdx >= 0 ? c.audio.playNext : null,
      iconSize: _iconSize,
      icon: const Icon(Icons.skip_next),
    );
  }

  _buildLoopModeButton() {
    return IconButton(
      key: const Key('loop_mode'),
      onPressed: c.audio.onLoopModePressed,
      iconSize: _iconSize * 0.5,
      icon: c.audio.loopMode.value == LoopMode.allLoop
          ? const Icon(Icons.repeat)
          : const Icon(Icons.repeat_one),
    );
  }
}
