import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'window_buttons.dart';

void main() async {
  // window acrylic, mica or transparency effects
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyAppBody(),
    );
  }
}

class MyAppBody extends StatefulWidget {
  const MyAppBody({super.key});

  @override
  State<MyAppBody> createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
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
      // dark: brightness == InterfaceBrightness.dark,
    );
    setState(() => effect = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowTitleBarBox(
          child: Row(
            children: [Expanded(child: MoveWindow()), const WindowButtons()],
          ),
        ),
      ],
    );
  }
}
