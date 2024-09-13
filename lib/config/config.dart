import 'package:again/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

final configProvider = Provider<JsonStorage>((ref) {
  return JsonStorage(filePath: p.join('config', 'config.json'));
});
