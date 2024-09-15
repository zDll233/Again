import 'package:again/audio/audio_notifier.dart';
import 'package:again/audio/audio_providers.dart';
import 'package:again/audio/audio_state.dart';
import 'package:again/screens/components/rectangle_overlay_shape.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerWidget extends ConsumerStatefulWidget {
  static const double _iconSize = 45.0;

  const PlayerWidget({
    super.key,
  });

  @override
  ConsumerState<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends ConsumerState<PlayerWidget> {
  late final AudioNotifier audioNotifier;
  @override
  void initState() {
    audioNotifier = ref.read(audioProvider.notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appWidth = MediaQuery.of(context).size.width;
    return SizedBox(
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
          audioNotifier.seek(Duration(
              milliseconds: ref.watch(audioProvider).position.inMilliseconds +
                  milliseconds));
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
              final duration = ref.watch(audioProvider).duration;
              if (duration != Duration.zero) {
                final position = value * duration.inMilliseconds;
                audioNotifier.seek(Duration(milliseconds: position.round()));
              }
            },
            value: _getProgressBarValue(),
          ),
        ),
      ),
    );
  }

  double _getProgressBarValue() {
    final duration = ref.watch(audioProvider).duration;
    final position = ref.watch(audioProvider).position;

    if (position != Duration.zero &&
        duration != Duration.zero &&
        position.inMilliseconds > 0 &&
        position.inMilliseconds < duration.inMilliseconds) {
      return position.inMilliseconds / duration.inMilliseconds;
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
    final duration = ref.watch(audioProvider).duration;
    final position = ref.watch(audioProvider).position;

    if (position != Duration.zero) {
      return '${position.toString().split('.').first} / ${duration.toString().split('.').first}';
    } else if (duration != Duration.zero) {
      return duration.toString().split('.').first;
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
      onPressed: ref.read(miscUIProvider.notifier).toggleShowLyricPanel,
      iconSize: PlayerWidget._iconSize * 0.5,
      icon: ref.watch(miscUIProvider).showLyricPanel
          ? const Icon(Icons.arrow_drop_down)
          : const Icon(Icons.arrow_drop_up),
    );
  }

  Widget _buildPrevButton() {
    return IconButton(
      key: const Key('prev_button'),
      onPressed: ref.read(voiceItemProvider).playingIndex >= 0
          ? audioNotifier.playPrev
          : null,
      iconSize: PlayerWidget._iconSize,
      icon: const Icon(Icons.skip_previous),
      padding: const EdgeInsets.all(2.5),
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      key: const Key('play_pause_button'),
      onPressed: ref.read(voiceItemProvider).playingIndex >= 0
          ? audioNotifier.switchPauseResume
          : null,
      iconSize: PlayerWidget._iconSize,
      icon: ref.watch(audioProvider).playerState == PlayerState.playing
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow),
      padding: const EdgeInsets.all(2.5),
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      key: const Key('next_button'),
      onPressed: ref.read(voiceItemProvider).playingIndex >= 0
          ? audioNotifier.playNext
          : null,
      iconSize: PlayerWidget._iconSize,
      icon: const Icon(Icons.skip_next),
      padding: const EdgeInsets.all(2.5),
    );
  }

  _buildLoopModeButton() {
    return IconButton(
      key: const Key('loop_mode'),
      onPressed: audioNotifier.onLoopModePressed,
      iconSize: PlayerWidget._iconSize * 0.5,
      icon: ref.watch(audioProvider).loopMode == LoopMode.allLoop
          ? const Icon(Icons.repeat)
          : const Icon(Icons.repeat_one),
    );
  }

  Widget _buildVolumeControl(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDelta = pointerSignal.scrollDelta.dy;
          final volume = ref.read(audioProvider).volume;
          if (scrollDelta > 0) {
            audioNotifier.setVolume((volume - 0.1).clamp(0.0, 1.0));
          } else if (scrollDelta < 0) {
            audioNotifier.setVolume((volume + 0.1).clamp(0.0, 1.0));
          }
        }
      },
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            IconButton(
              onPressed: audioNotifier.onMutePressed,
              icon: ref.watch(audioProvider).volume == 0
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
                  value: ref.watch(audioProvider).volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (double value) {
                    audioNotifier.setVolume(value);
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
