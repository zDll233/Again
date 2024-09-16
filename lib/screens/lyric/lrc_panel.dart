import 'dart:io';

import 'package:again/audio/audio_providers.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class LyricPanel extends ConsumerStatefulWidget {
  const LyricPanel({
    super.key,
  });

  @override
  ConsumerState<LyricPanel> createState() => _LyricPanelState();
}

class _LyricPanelState extends ConsumerState<LyricPanel> {
  final lyricUi = UINetease(
      otherMainColor: Colors.white60, highLightTextColor: Colors.purple[200]);

  bool _hasLyric = false;
  bool _readLyric = false;
  @override
  Widget build(BuildContext context) {
    final hasAudioSource =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));

    return hasAudioSource ? _lrcPanelBuilder(context) : _emptyBuilder();
  }

  Widget _lrcPanelBuilder(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50.0,
          child: _viTitleBuilder(context),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _lrcBuilder(context),
        ),
      ],
    );
  }

  Widget _viTitleBuilder(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: Consumer(
        builder: (_, WidgetRef ref, __) {
          final playingViPath = ref.watch(voiceItemProvider
              .select((state) => state.cachedPlayingVoiceItemPath!));
          return TextButton(
              onPressed: ref.read(uiServiceProvider).selectPlayingVoiceItem,
              child: Text(
                p.basenameWithoutExtension(playingViPath),
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ));
        },
      ),
    );
  }

  Widget _lrcBuilder(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final playingViPath = ref.watch(voiceItemProvider
          .select((state) => state.cachedPlayingVoiceItemPath!));

      final appSize = MediaQuery.of(context).size;
      final size = Size(appSize.width * 0.70, appSize.height - 210.0);

      return FutureBuilder<String>(
        future: _getLrcContent(playingViPath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading lyrics'));
          } else {
            final lrcContent = snapshot.data ?? '';
            final cachedLyricModel = _getLrcModel(lrcContent);

            return Consumer(
              builder: (_, WidgetRef ref, __) {
                final position =
                    ref.watch(audioProvider.select((state) => state.position));
                final isPlaying =
                    ref.watch(audioProvider.select((state) => state.isPlaying));
                return LyricsReader(
                  model: cachedLyricModel,
                  position: position.inMilliseconds,
                  playing: isPlaying,
                  size: size,
                  emptyBuilder: _emptyBuilder,
                  selectLineBuilder: (position, flashBack, confirmPlay) =>
                      _lineIndicator(
                          context, position, flashBack, confirmPlay, isPlaying),
                  lyricUi: lyricUi,
                  waitMilliseconds: 5000,
                  canScrollBack: isPlaying,
                  canFlashBack: true,
                );
              },
            );
          }
        },
      );
    });
  }

  Widget _emptyBuilder() {
    return Center(
      child: Text(
        _hasLyric
            ? _readLyric
                ? 'Cannot read lyric file'
                : 'Incorrect lyric format'
            : 'No lyric',
      ),
    );
  }

  Widget _lineIndicator(BuildContext context, int position,
      VoidCallback flashBack, VoidCallback confirmPlay, bool isPlaying) {
    final audioNotifier = ref.read(audioProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: IconButton(
              onPressed: () {
                flashBack.call();
              },
              icon: const Icon(Icons.location_searching),
            ),
          ),
        ),
        Flexible(
          flex: 8,
          child: Container(
            decoration: const BoxDecoration(color: Colors.grey),
            height: 1,
            width: double.infinity,
          ),
        ),
        Flexible(
          flex: 1,
          child: TextButton(
            child: Text(
                Duration(milliseconds: position).toString().split('.').first,
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () {
              audioNotifier.seek(Duration(milliseconds: position));
              confirmPlay.call();
              if (!isPlaying) {
                audioNotifier.resume();
              }
            },
          ),
        ),
      ],
    );
  }

  Future<String> _getLrcContent(String playingViPath) async {
    final lrcPath = p.setExtension(playingViPath, '.lrc');

    try {
      final file = File(lrcPath);
      _hasLyric = true;
      final result = await file.readAsString();
      _readLyric = true;
      return result;
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 2) {
        // 错误码2表示文件未找到
        _hasLyric = false;
        return '';
      } else {
        _readLyric = false;
        return '';
      }
    } catch (e) {
      Log.error('Uncaught error in getting lyric content.\n$e.');
      return '';
    }
  }

  LyricsReaderModel _getLrcModel(String lrcContent) {
    return LyricsModelBuilder.create().bindLyricToMain(lrcContent).getModel();
  }
}
