import 'dart:io';

import 'package:again/controllers/controller.dart';
import 'package:again/utils/log.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

bool hasLyric = false;
bool readLyric = false;

class LyricPanel extends StatelessWidget {
  LyricPanel({super.key});

  final Controller c = Get.find();

  final lyricUi = UINetease(
      otherMainColor: Colors.white60, highLightTextColor: Colors.purple[200]);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return c.audio.playingViIdx.value >= 0 &&
              c.audio.playingViPathList.isNotEmpty
          ? _lrcPanelBuilder(context)
          : _emptyBuilder();
    });
  }

  Widget _lrcPanelBuilder(BuildContext context) {
    String playingViPath = c.audio.playingViPath;
    return Column(
      children: [
        SizedBox(
          height: 50.0,
          child: _viTitleBuilder(context, playingViPath),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _lrcBuilder(context, playingViPath),
        ),
      ],
    );
  }

  Widget _viTitleBuilder(BuildContext context, String playingViPath) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: TextButton(
        onPressed: c.ui.selectPlayingViFile,
        child: Text(
          p.basenameWithoutExtension(playingViPath),
          style: Theme.of(context).textTheme.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _lrcBuilder(BuildContext context, String lrcPath) {
    return FutureBuilder<String>(
      future: _getLrcContent(lrcPath),
      builder: (context, snapshot) {
        final appSize = MediaQuery.of(context).size;
        final size = Size(appSize.width * 0.70, appSize.height - 210.0);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading lyrics"));
        } else {
          final lrcContent = snapshot.data ?? '';
          final lyricModel = _getLrcModel(lrcContent);
          return Obx(() => LyricsReader(
                model: lyricModel,
                position: c.audio.position.value.inMilliseconds,
                playing: c.audio.playerState.value == PlayerState.playing,
                size: size,
                emptyBuilder: _emptyBuilder,
                selectLineBuilder: (position, flashBack, confirmPlay) =>
                    _lineIndicator(context, position, flashBack,
                        confirmPlay), // 传递 context
                lyricUi: lyricUi,
                waitMilliseconds: 5000,
                canScrollBack: c.audio.playerState.value == PlayerState.playing,
                canFlashBack: true,
              ));
        }
      },
    );
  }

  Widget _emptyBuilder() {
    return Center(
      child: Text(
        hasLyric
            ? readLyric
                ? "Can't read lyric file"
                : "Incorrect lyric format"
            : "No lyric",
      ),
    );
  }

  Widget _lineIndicator(BuildContext context, int position,
      VoidCallback flashBack, VoidCallback confirmPlay) {
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
              c.audio.player.seek(Duration(milliseconds: position));
              confirmPlay.call();
              if (c.audio.playerState.value != PlayerState.playing) {
                c.audio.resume();
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
      hasLyric = true;
      String result = await file.readAsString();
      readLyric = true;
      return result;
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 2) {
        // 错误码2表示文件未找到
        hasLyric = false;
        return '';
      } else {
        readLyric = false;
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
