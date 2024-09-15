import 'package:again/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

final configProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: p.join('config', 'config.json'));
});

final historyProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: p.join('history', 'last_played.json'));
});
