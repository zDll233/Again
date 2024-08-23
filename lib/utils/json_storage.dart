import 'dart:io';
import 'dart:convert';

import 'package:again/utils/log.dart';

class JsonStorage {
  final String filePath;

  JsonStorage({required this.filePath});

  Future<Map<String, dynamic>> read() async {
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      Log.error("Error reading $filePath: $e.");
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> data) async {
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final contents = json.encode(data);
    await file.writeAsString(contents);
  }
}
