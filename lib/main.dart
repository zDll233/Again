import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart';

import 'database/database.dart';
import 'window_buttons.dart';
import 'simple_audio_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // for window acrylic, mica or transparency effects
  await Window.initialize();

  // =============================================
  // final database = AppDatabase();

  // await database
  //     .into(database.voiceWorkCategory)
  //     .insert(VoiceWorkCategoryCompanion.insert(description: 'Marked'));

  // await database.into(database.voiceWork).insert(VoiceWorkCompanion.insert(
  //       title: '陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～',
  //       diretoryPath:
  //           'E:\\Media\\ACG\\音声\\Marked\\陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～',
  //       category: 1,
  //     ));

  // await database.into(database.voiceItem).insert(VoiceItemCompanion.insert(
  //     title: 'とらっく２ りなと添い寝',
  //     filePath:
  //         'E:\\Media\\ACG\\音声\\Marked\\陽向葵ゅか-【 一緒に眠る ASMR】不眠症の眠り姫～あなたと眠る異世界生活～\\RJ01129638\\WAV\\とらっく1 りなと添い寝.wav',
  //     voiceWorkId: 1));

  // List<VoiceItemData> allItems =
  //     await database.select(database.voiceItem).get();

  // =============================================

  runApp(const MyApp());

  // custom titlebar/buttons
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      const initialSize = Size(960, 540);
      appWindow
        ..minSize = initialSize
        ..size = initialSize
        ..alignment = Alignment.center
        ..title = "Again"
        ..show();
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WindowEffect effect = WindowEffect.transparent;
  Color color = const Color(0xCC222222);

  @override
  void initState() {
    super.initState();
    setWindowEffect(effect);
  }

  void setWindowEffect(WindowEffect? value) {
    Window.setEffect(
      effect: value!,
      color: color,
    );
    setState(() => effect = value);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                WindowTitleBarBox(
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      const WindowButtons()
                    ],
                  ),
                ),
                const SimpleAudioPlayer()
              ],
            )));
  }
}
