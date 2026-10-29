import 'dart:io';

/// 从 [FileStat] 里取「加入本地库的时间」: Windows 用**创建时间**, 其他平台
/// 回退修改时间。
///
/// dart:io 的 [FileStat.changed] 在 Windows 上就是创建时间 (NTFS 上末次属性
/// 变更时间与创建时间同源; 实测对文件和目录都成立, 见 test/file_time_test.dart
/// 守护这一假设)。比 CreateFileW + GetFileTime 的 FFI 方案省两次系统调用 ——
/// 一次扫描要为几千个音轨取时间。
///
/// Android/Linux 不能这么做: 那边的 `changed` 是 inode 变更时间 (写文件就会变),
/// 所以直接回退 mtime, 与历史行为一致。
DateTime creationOrModifiedTime(FileStat stat) =>
    Platform.isWindows ? stat.changed : stat.modified;
