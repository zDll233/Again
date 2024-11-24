import 'dart:io';

import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/line_indicator.dart';
import 'package:again/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

class LyricBuilder extends ConsumerStatefulWidget {
  const LyricBuilder({super.key});

  @override
  ConsumerState<LyricBuilder> createState() => _LrcBuilderState();
}

class _LrcBuilderState extends ConsumerState<LyricBuilder> {
  bool _haveLyric = false;
  bool _readLyric = false;
  final lyricUi = UINetease(
    otherMainColor: Colors.white60,
    highLightTextColor: Colors.purple[200],
  );

  @override
  Widget build(BuildContext context) {
    final playingViPath = ref.watch(
        voiceItemProvider.select((state) => state.cachedPlayingVoiceItemPath!));

    final appSize = MediaQuery.of(context).size;
    final size = Size(appSize.width * 0.70, appSize.height - 210.0);

    return FutureBuilder<String>(
      future: _getLrcContent(playingViPath),
      builder: (context, snapshot) {
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
                emptyBuilder: () => EmptyLyric(
                  haveLyric: _haveLyric,
                  readLyric: _readLyric,
                ),
                selectLineBuilder: (position, flashBack, confirmPlay) =>
                    LineIndicator(
                  ref: ref,
                  context: context,
                  position: position,
                  flashBack: flashBack,
                  confirmPlay: confirmPlay,
                  isPlaying: isPlaying,
                ),
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
  }

  Future<String> _getLrcContent(String playingViPath) async {
    final lrcPath = p.setExtension(playingViPath, '.lrc');

    try {
      final file = File(lrcPath);
      _haveLyric = true;
      final result = await file.readAsString();
      _readLyric = true;
      return result;
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 2) {
        // 错误码2表示文件未找到
        _haveLyric = false;
      } else {
        _readLyric = false;
      }
      return '';
    } catch (e) {
      Log.error('Uncaught error in getting lyric content.\n$e.');
      return '';
    }
  }

  LyricsReaderModel _getLrcModel(String lrcContent) {
    return LyricsModelBuilder.create().bindLyricToMain(lrcContent).getModel();
  }
}
