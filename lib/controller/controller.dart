import 'dart:async';

import 'package:again/utils/json_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

import 'package:path/path.dart' as p;

class Controller extends GetxController {
  final audio = Get.put(AudioController());
  final ui = Get.put(UIController());
  final db = Get.put(DatabaseController());

  late final JsonStorage _history;

  @override
  void onInit() async {
    super.onInit();
    await db.initializeStorage();
    await _loadHistory();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void onClose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        audio.onPausePressed();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _startSeek(-10000);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _startSeek(10000);
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        ui.showLrcPanel.value = true;
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        ui.showLrcPanel.value = false;
        return true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _stopSeekTimer();
        return true;
      }
    }
    return false;
  }

  Timer? _seekTimer;

  void _startSeek(int milliseconds) {
    _stopSeekTimer(); // cacel last timer, avoid shaking progress

    audio.player.seek(Duration(
        milliseconds: audio.position.value.inMilliseconds + milliseconds));

    _seekTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _seekTimer?.cancel();
      _seekTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        audio.player.seek(Duration(
            milliseconds: audio.position.value.inMilliseconds + milliseconds));
      });
    });
  }

  void _stopSeekTimer() {
    _seekTimer?.cancel();
    _seekTimer = null;
  }

  Future<void> saveHistory() async {
    Map<String, dynamic> lastPlayed = {
      'ui': {
        'filter': {
          'category': ui.playingCategoryIdx.value,
          'cv': ui.playingCvIdx.value,
          'sortOrder': ui.sortOrder.value.index
        },
        'vk': ui.playingVkIdx.value,
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
    const directoryPath = 'history';
    const fileName = 'last_played.json';
    final filePath = p.join(directoryPath, fileName);

    _history = JsonStorage(filePath: filePath);
    final data = await _history.read();
    if (data.isEmpty) return;

    try {
      await ui.loadHistory(data['ui']);
      await audio.loadHistory(data['audio']);
    } catch (_) {}
  }
}
