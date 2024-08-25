import 'dart:async';
import 'dart:io';
import 'package:again/utils/log.dart';
import 'package:path/path.dart' as path;

Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (e) {
    Log.error("Error renaming file ${sourceFile.path} to $newPath, start to copy and delete it. $e.");
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

Future<Directory> moveDirectory(Directory sourceDir, String newPath) async {
  try {
    return await sourceDir.rename(newPath);
  } catch (e) {
    Log.error("Error renaming directory ${sourceDir.path} to $newPath, start to copy and delete it. $e.");

    final newDir = Directory(newPath);
    await newDir.create(recursive: true);
    await for (var entity in sourceDir.list(recursive: false)) {
      final entityName = path.basename(entity.path);
      final newEntityPath = path.join(newDir.path, entityName);

      if (entity is File) {
        await moveFile(entity, newEntityPath);
      } else if (entity is Directory) {
        await moveDirectory(entity, newEntityPath);
      }
    }
    // 删除源目录
    await sourceDir.delete(recursive: true);
    return newDir;
  }
}
