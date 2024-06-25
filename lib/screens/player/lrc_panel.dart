import 'dart:io';

import 'package:again/controller/controller.dart';
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
      final playingViIdx = c.audio.playingViIdx.value;
      final playingViPathList = c.audio.playingViPathList.toList();
      return playingViIdx >= 0 && playingViPathList.isNotEmpty
          ? _lrcPanelBuilder(playingViIdx, playingViPathList, context)
          : _emptyBuilder();
    });
  }

  Widget _lrcPanelBuilder(
      int playingViIdx, List playingViPathList, BuildContext context) {
    String playingViPath = playingViPathList[playingViIdx];
    return Column(
      children: [
        SizedBox(
          height: 50.0,
          child: TextButton(
            onPressed: c.ui.slectPlayingViFile,
            child: Text(
              p.basenameWithoutExtension(playingViPath),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _lrcBuilder(context, playingViPath),
        ),
      ],
    );
  }

  Widget _lrcBuilder(BuildContext context, String lrcPath) {
    return FutureBuilder<String>(
      future: _getLrcContent(lrcPath),
      builder: (context, snapshot) {
        final mediaSize = MediaQuery.of(context).size;
        final size = Size(mediaSize.width * 0.60, mediaSize.height - 210.0);

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
                selectLineBuilder: _lineIndicator,
                lyricUi: lyricUi,
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

  Widget _lineIndicator(int progress, VoidCallback confirm) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            LyricsLog.logD("点击事件");
            confirm.call();
            c.audio.player.seek(Duration(milliseconds: progress));
            if (c.audio.playerState.value != PlayerState.playing) {
              c.audio.resume();
            }
          },
          icon: const Icon(Icons.play_arrow),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: Colors.grey),
            height: 1,
            width: double.infinity,
          ),
        ),
        Text(
          '    ${Duration(milliseconds: progress).toString().split('.').first}',
        )
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
    } catch (_) {
      return '';
    }
  }

  LyricsReaderModel _getLrcModel(String lrcContent) {
    return LyricsModelBuilder.create().bindLyricToMain(lrcContent).getModel();
  }
}
