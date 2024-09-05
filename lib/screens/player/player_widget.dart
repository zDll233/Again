import 'package:again/components/rectangle_overlay_shape.dart';
import 'package:again/controllers/audio_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:again/controllers/controller.dart';

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
        height: 100,
        child: Stack(
          children: [
            MoveWindow(),
            Positioned(
              top: 10,
              child: _buildProgressBar(context, appWidth),
            ),
            Positioned(
              left: 20,
              bottom: 25,
              child: _buildTimeDisplay(context),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 5,
              child: _buildPlaybackControls(),
            ),
            Positioned(
              right: 10,
              bottom: 15,
              child: _buildVolumeControl(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double appWidth) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDelta = pointerSignal.scrollDelta.dy;
          var milliseconds = 0;
          if (scrollDelta > 0) {
            milliseconds = -10000;
          } else if (scrollDelta < 0) {
            milliseconds = 10000;
          }
          c.audio.player.seek(Duration(
              milliseconds:
                  c.audio.position.value.inMilliseconds + milliseconds));
        }
      },
      child: SizedBox(
        height: 40,
        width: appWidth,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 1.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
          ),
          child: Slider(
            focusNode: FocusNode(canRequestFocus: false),
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

  Widget _buildTimeDisplay(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Text(_getTimeDisplayText(),
            style: Theme.of(context).textTheme.bodyLarge));
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
    // return Align(
    return Container(
      height: 60.0,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildShowLryicButton(),
          _buildPrevButton(),
          _buildPlayPauseButton(),
          _buildNextButton(),
          _buildLoopModeButton(),
        ],
      ),
    );
  }

  Widget _buildShowLryicButton() {
    return IconButton(
      key: const Key('lyric_button'),
      onPressed: c.ui.showLrcPanel.toggle,
      iconSize: _iconSize * 0.5,
      icon: c.ui.showLrcPanel.value
          ? const Icon(Icons.arrow_drop_down)
          : const Icon(Icons.arrow_drop_up),
    );
  }

  Widget _buildPrevButton() {
    return IconButton(
      key: const Key('prev_button'),
      onPressed: c.audio.playingViIdx >= 0 ? c.audio.playPrev : null,
      iconSize: _iconSize,
      icon: const Icon(Icons.skip_previous),
      padding: const EdgeInsets.all(2.5),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      key: const Key('play_pause_button'),
      onPressed: c.audio.playingViIdx >= 0 ? c.audio.switchPauseResume : null,
      iconSize: _iconSize,
      icon: c.audio.playerState.value == PlayerState.playing
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow),
      padding: const EdgeInsets.all(2.5),
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      key: const Key('next_button'),
      onPressed: c.audio.playingViIdx >= 0 ? c.audio.playNext : null,
      iconSize: _iconSize,
      icon: const Icon(Icons.skip_next),
      padding: const EdgeInsets.all(2.5),
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

  Widget _buildVolumeControl(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDelta = pointerSignal.scrollDelta.dy;
          if (scrollDelta > 0) {
            c.audio.setVolume((c.audio.volume.value - 0.1).clamp(0.0, 1.0));
          } else if (scrollDelta < 0) {
            c.audio.setVolume((c.audio.volume.value + 0.1).clamp(0.0, 1.0));
          }
        }
      },
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
                        const RoundSliderThumbShape(enabledThumbRadius: 0.0),
                    overlayShape: RectangleOverlayShape(
                        shapeSize: const Size(10.0, 40.0)),
                    overlayColor: Colors.transparent),
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
}
