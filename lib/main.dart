import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart';

import 'controller/simple_audio_player.dart';
import 'screens/button_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // for window acrylic, mica or transparency effects
  await Window.initialize();

  // =============================================

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
                  const SimpleAudioPlayer(),
              ],
            )));
  }
}
