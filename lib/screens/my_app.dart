import 'dart:ui';
import 'package:again/controllers/controller.dart';
import 'package:again/screens/list_lyric_switch.dart';
import 'package:again/screens/player/player_widget.dart';
import 'package:again/screens/window_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          brightness: Brightness.dark,
        )),
        scrollBehavior: MyCustomScrollBehavior(),
        home: Scaffold(
            backgroundColor: Colors.transparent,
            body: FocusScope(
              canRequestFocus: false,
              child: Column(
                children: [
                  const WindowTitleBar(),
                  ListLyricSwitch(),
                  PlayerWidget(player: c.audio.player)
                ],
              ),
            )));
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // default
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        // enable mouse && trackpad
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}
