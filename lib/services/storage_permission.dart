import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// 音声根目录所在的外部存储是否可直接用文件系统路径访问。
/// 非 Android 恒为 true。
Future<bool> hasExternalStorageAccess() async {
  if (!Platform.isAndroid) return true;
  return await Permission.manageExternalStorage.isGranted;
}

/// 请求外部存储访问权限 (Android 11+ 跳系统"所有文件访问"设置页,
/// 返回后检查结果)。
Future<bool> requestExternalStorageAccess() async {
  if (!Platform.isAndroid) return true;
  if (await hasExternalStorageAccess()) return true;
  final status = await Permission.manageExternalStorage.request();
  if (status.isGranted) return true;
  // Android 10 及以下无全文件访问权限, 回退传统存储权限
  return await Permission.storage.request().isGranted;
}
