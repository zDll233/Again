import 'dart:async';

import 'package:again/utils/key_event_handler.dart';
import 'package:again/utils/generate_script.dart';
import 'package:again/utils/json_storage.dart';
import 'package:again/utils/log.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

class Controller extends GetxController {
  final audio = Get.put(AudioController());
  final ui = Get.put(UIController());
  final db = Get.put(DatabaseController());

  late final JsonStorage _history;
  late final KeyEventHandler _keyEventHandler;

  @override
  void onInit() async {
    super.onInit();
    await _initialize();
    _keyEventHandler = KeyEventHandler(audio, ui);
    HardwareKeyboard.instance.addHandler(_keyEventHandler.handleKeyEvent);
  }

  Future<void> _initialize() async {
    await db.initializeStorage();
    await _loadHistory();
    initializeScript();
  }

  void initializeScript() {
    generateDeleteScript();
  }

  @override
  void onClose() {
    HardwareKeyboard.instance.removeHandler(_keyEventHandler.handleKeyEvent);
  }

  Future<void> saveHistory() async {
    final playingData = await ui.playingStringMap;

    Map<String, dynamic> lastPlayed = {
      'ui': {
        'filter': {
          'category': playingData['category'],
          'cv': playingData['cv'],
          'sortOrder': ui.sortOrder.value.index
        },
        'vk': playingData['vk'],
        'vi': audio.playingViIdx.value
      },
      'audio': {
        'position': audio.position.value.inMilliseconds,
        'volume': audio.volume.value,
        'loopMode': audio.loopMode.value.index
      },
    };
    await _history.write(lastPlayed);
  }

  Future<void> _loadHistory() async {
    final filePath = p.join('history', 'last_played.json');

    _history = JsonStorage(filePath: filePath);
    final data = await _history.read();
    if (data.isEmpty) return;

    await db.updateFilterLists();
    try {
      await ui.loadHistory(data['ui']);
      await audio.loadHistory(data['audio']);
    } catch (e) {
      await db.updateVkList();

      Log.error('Error loading history.\n$e.');
    }
  }
}
