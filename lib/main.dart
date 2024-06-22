import 'dart:io';

import 'package:again/controller/controller.dart';
import 'package:again/screens/player/player_widget.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart';

import 'screens/home.dart';
import 'screens/window_title_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // for window acrylic, mica or transparency effects
  await Window.initialize();
  Window.setEffect(
    effect: WindowEffect.transparent,
    color: const Color(0xCC222222),
  );

  runApp(const MyApp());

  // custom titlebar/buttons
  if (Platform.isWindows) {
    doWhenWindowReady(() {
      const initialSize = Size(1010, 690);
      appWindow
        ..minSize = initialSize
        ..size = initialSize
        ..alignment = Alignment.center
        ..title = "Again"
        ..show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => Controller());
    final Controller c = Get.find();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        )),
        home: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                const WindowTitleBar(),
                Home(),
                PlayerWidget(player: c.audio.player)
              ],
            )));
  }
}
