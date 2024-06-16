import 'package:again/utils/json_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'audio_controller.dart';
import 'database_controller.dart';
import 'u_i_controller.dart';

import 'package:path/path.dart' as p;

class Controller extends GetxController {
  final audio = Get.put(AudioController());
  final ui = Get.put(UIController());
  final db = Get.put(DatabaseController());

  late final JsonStorage _cache;

  @override
  void onInit() async {
    super.onInit();
    await db.initializeStorage();
    await _loadCache();
  }

  Future<void> saveCache() async {
    final AudioController audio = Get.find();
    Map<String, dynamic> lastPlayed = {
      'ui': {
        'filter': {
          'category': ui.playingCategoryIdx.value,
          'cv': ui.playingCvIdx.value,
          'sortOrder': ui.sortOrder.value.index
        },
        'vk': ui.playingVkIdx.value,
        'scrollOffset': {
          'cvOffset': ui.cvOffsetMap[ui.playingCvIdx.value],
          'vkOffset': ui.vkOffsetMap[ui.playingVkIdx.value],
        },
      },
      'audio': {
        'vi': audio.playingViIdx.value,
        'position': audio.position.value.inMilliseconds,
        'volume': audio.volume.value,
        'loopMode':audio.loopMode.value.index
      },
    };
    await _cache.write(lastPlayed);
  }

  Future<void> _loadCache() async {
    const directoryPath = 'cache';
    const fileName = 'last_played.json';
    final filePath = p.join(directoryPath, fileName);

    _cache = JsonStorage(filePath: filePath);
    final data = await _cache.read();
    if (data.isEmpty) return;

    await ui.loadCache(data['ui']);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 延迟滚动到保存的位置
      await ui.scrollToPlayingOffsets();

      await audio.loadCache(data['audio']);
    });
  }
}
