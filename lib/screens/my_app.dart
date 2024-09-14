import 'dart:ui';
import 'package:again/repository/repository_providers.dart';
import 'package:again/screens/list_lyric_switch.dart';
import 'package:again/screens/player/player_widget.dart';
import 'package:again/screens/window_title_bar.dart';
import 'package:again/service/history_manager.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/service/key_event_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final KeyEventHandler _keyEventHandler;

  @override
  Future<void> initState() async {
    super.initState();

    await _initialize();
    _keyEventHandler = KeyEventHandler(ref as Ref<Object?>);
    HardwareKeyboard.instance.addHandler(_keyEventHandler.handleKeyEvent);
  }

  Future<void> _initialize() async {
    await ref.read(repositoryProvider.notifier).initializeStorage();
    await ref.read(historyManagerProvider).loadHistory();
    initializeScript();
  }

  void initializeScript() {
    generateDeleteScript();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyEventHandler.handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          brightness: Brightness.dark,
        )),
        scrollBehavior: MyCustomScrollBehavior(),
        home: const Scaffold(
            backgroundColor: Colors.transparent,
            body: FocusScope(
              canRequestFocus: false,
              child: Column(
                children: [
                  WindowTitleBar(),
                  ListLyricSwitch(),
                  PlayerWidget()
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
