import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:again/utils/log.dart';
import 'package:http/http.dart' as http;

/// 当前应用版本 (CI 构建时通过 --dart-define=APP_VERSION 注入, 本地为 dev)。
const String kAppVersion =
    String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

/// 检查更新结果。
class UpdateCheckResult {
  final String latestTag; // 如 v0.4.4
  final String? zipUrl; // Release 压缩包资产 URL
  final String? releaseUrl; // Release 页面

  const UpdateCheckResult({
    required this.latestTag,
    this.zipUrl,
    this.releaseUrl,
  });

  /// 最新版本是否比当前版本新。
  bool get hasUpdate => compareVersions(latestTag, kAppVersion) > 0;
}

/// 比较版本号 (v1.2.3 风格, 忽略 v 前缀), 返回正数/0/负数。
int compareVersions(String a, String b) {
  final pa = _parts(a);
  final pb = _parts(b);
  final len = pa.length > pb.length ? pa.length : pb.length;
  for (var i = 0; i < len; i++) {
    final na = i < pa.length ? pa[i] : 0;
    final nb = i < pb.length ? pb[i] : 0;
    if (na != nb) return na - nb;
  }
  return 0;
}

List<int> _parts(String version) {
  return version
      .replaceFirst('v', '')
      .split('.')
      .map((s) => int.tryParse(s.trim()) ?? 0)
      .toList();
}

/// 清理历史更新残留的临时目录 (again_update_*)。
Future<void> cleanStaleUpdateDirs() async {
  try {
    final tempDir = await Directory.systemTemp.createTemp('again_update_');
    final tempRoot = tempDir.parent;
    await tempDir.delete(recursive: true);
    await for (final entity in tempRoot.list()) {
      if (entity is Directory &&
          entity.path.contains('again_update_')) {
        await entity.delete(recursive: true);
      }
    }
  } catch (e) {
    Log.error('Clean stale update dirs error: $e');
  }
}

/// 查询 GitHub 最新 Release。
Future<UpdateCheckResult?> checkForUpdate() async {
  // 顺手清理历史下载残留
  unawaited(cleanStaleUpdateDirs());
  try {
    final resp = await http.get(
      Uri.parse('https://api.github.com/repos/zDll233/Again/releases/latest'),
      headers: {'Accept': 'application/vnd.github+json'},
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      Log.info('Check update failed: HTTP ${resp.statusCode}');
      return null;
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final tag = (json['tag_name'] as String?) ?? '';
    final assets = (json['assets'] as List<dynamic>?) ?? [];
    String? zipUrl;
    for (final asset in assets) {
      final name = (asset as Map<String, dynamic>)['name'] as String? ?? '';
      if (name.endsWith('.zip')) {
        zipUrl = asset['browser_download_url'] as String?;
        break;
      }
    }
    return UpdateCheckResult(
      latestTag: tag,
      zipUrl: zipUrl,
      releaseUrl: json['html_url'] as String?,
    );
  } catch (e) {
    Log.error('Check update error: $e');
    return null;
  }
}

/// 下载 zip 到临时目录, 返回本地路径。
Future<String?> downloadUpdateZip(String url) async {
  try {
    final resp = await http.get(Uri.parse(url)).timeout(
          const Duration(minutes: 10),
        );
    if (resp.statusCode != 200) {
      Log.error('Download update failed: HTTP ${resp.statusCode}');
      return null;
    }
    final tempDir = await Directory.systemTemp.createTemp('again_update_');
    final zipPath =
        '${tempDir.path}${Platform.pathSeparator}update.zip';
    await File(zipPath).writeAsBytes(resp.bodyBytes);
    return zipPath;
  } catch (e) {
    Log.error('Download update error: $e');
    return null;
  }
}

/// 启动更新安装脚本并退出应用。
/// 脚本等待应用退出后解压覆盖 Release 目录, 再重启应用。
/// 执行过程写入 update_log.txt 便于排查。
Future<void> applyUpdate(String zipPath) async {
  final exePath = Platform.resolvedExecutable;
  final appDir = File(exePath).parent.path;
  final batPath = '$appDir${Platform.pathSeparator}update_again.bat';
  final logPath = '$appDir${Platform.pathSeparator}update_log.txt';
  final script = '''
@echo off
echo %date% %time% start >> "%LOG%"
timeout /t 2 /nobreak > nul
taskkill /f /im Again.exe > nul 2>&1
ping -n 3 127.0.0.1 > nul
echo %date% %time% killed >> "%LOG%"
powershell -NoProfile -Command "Expand-Archive -Force -LiteralPath '%ZIP%' -DestinationPath '%DIR%'" >> "%LOG%" 2>&1
echo %date% %time% extracted >> "%LOG%"
if exist "%DIR%\\Again.exe" (
  echo %date% %time% done >> "%LOG%"
  del "%LOG%"
) else (
  echo %date% %time% FAILED: exe missing >> "%LOG%"
)
start "" "%DIR%\\Again.exe"
del "%~f0"
''';
  Log.info('applyUpdate: zip=$zipPath appDir=$appDir');
  try {
    await File(batPath).writeAsString(
      script
          .replaceAll('%ZIP%', zipPath)
          .replaceAll('%DIR%', appDir)
          .replaceAll('%LOG%', logPath),
    );
    // 用 PowerShell 隐藏窗口启动脚本, 避免 cmd 黑窗口闪现;
    // 必须 await 并给子进程启动时间, 否则 exit(0) 会杀死尚未创建的子进程
    final psCmd =
        'Start-Process -FilePath cmd.exe -ArgumentList "/c \'${batPath.replaceAll("'", "''")}\'" -WindowStyle Hidden';
    await Process.start(
      'powershell',
      ['-NoProfile', '-WindowStyle', 'Hidden', '-Command', psCmd],
      mode: ProcessStartMode.detached,
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));
  } catch (e) {
    Log.error('applyUpdate failed: $e');
  }
  exit(0);
}
