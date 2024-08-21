import 'dart:async';
import 'dart:io';

Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    return await sourceFile.rename(newPath);
  } on FileSystemException catch (_) {
    // if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}

Future<Directory> moveDirectory(Directory sourceDir, String newPath) async {
  try {
    return await sourceDir.rename(newPath);
  } on FileSystemException catch (_) {
    final newDir = Directory(newPath);
    await newDir.create(recursive: true);

    await for (var entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        final newFilePath = '${newDir.path}/${entity.uri.pathSegments.last}';
        await moveFile(entity, newFilePath);
      } else if (entity is Directory) {
        final newSubDirPath = '${newDir.path}/${entity.uri.pathSegments.last}';
        await moveDirectory(entity, newSubDirPath);
      }
    }

    // 删除源目录
    await sourceDir.delete(recursive: true);

    return newDir;
  }
}
