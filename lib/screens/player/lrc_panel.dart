import 'dart:io';

import 'package:again/controller/controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class LyricPanel extends StatelessWidget {
  LyricPanel({super.key});

  final Controller c = Get.find();
  final lyricUi = UINetease(highLightTextColor: Colors.purple[200]);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String playingViPath =
          c.audio.playingViPathList[c.audio.playingViIdx.value];
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
              child: Text(
            p.basenameWithoutExtension(playingViPath),
            style: const TextStyle(fontSize: 23),
          )),
          _lrcPanelBuilder(context, playingViPath),
        ],
      );
    });
  }

  Widget _lrcPanelBuilder(BuildContext context, String lrcPath) {
    return FutureBuilder<String>(
      future: _getLrcContent(lrcPath),
      builder: (context, snapshot) {
        final mediaSize = MediaQuery.of(context).size;
        final size = Size(mediaSize.width, mediaSize.height) * 0.70;

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
    return const Center(
      child: Text(
        "No lyrics",
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
          // style: const TextStyle(color: Colors.green),
        )
      ],
    );
  }

  Future<String> _getLrcContent(String playingViPath) async {
    final lrcPath = p.setExtension(playingViPath, '.lrc');

    try {
      final file = File(lrcPath);
      return await file.readAsString();
    } catch (_) {
      return '';
    }
  }

  LyricsReaderModel _getLrcModel(String lrcContent) {
    return LyricsModelBuilder.create().bindLyricToMain(lrcContent).getModel();
  }
}
