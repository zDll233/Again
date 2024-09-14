import 'dart:io';

import 'package:again/screens/my_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

Future<void> setupWindow(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    if (!kDebugMode) {
      await WindowsSingleInstance.ensureSingleInstance(args, 'again',
          onSecondWindow: null);
    }

    // for window acrylic, mica or transparency effects
    await Window.initialize();
    Window.setEffect(
      effect: WindowEffect.transparent,
      color: const Color(0xCC222222),
    );

    // custom titlebar/buttons
    doWhenWindowReady(() {
      const initialSize = Size(1040, 690);
      appWindow
        ..minSize = initialSize
        ..size = initialSize
        ..alignment = Alignment.center
        ..title = 'Again'
        ..show();
    });
  }
}

void main(List<String> args) async {
  await setupWindow(args);
  runApp(const ProviderScope(child: MyApp()));
}