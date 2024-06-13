import 'dart:io';
import 'dart:convert';

class JsonStorage {
  final String filePath;

  JsonStorage({required this.filePath});

  Future<Map<String, dynamic>> read() async {
    final file = File(filePath);
    if (await file.exists()) {
      final contents = await file.readAsString();
      return json.decode(contents) as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> data) async {
    final file = File(filePath);
    await file.create(recursive: true);
    final contents = json.encode(data);
    await file.writeAsString(contents);
  }
}
