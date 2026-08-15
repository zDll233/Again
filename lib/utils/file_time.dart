import 'dart:ffi';
import 'package:ffi/ffi.dart';

final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

typedef _CreateFileWNative = Pointer<Void> Function(
    Pointer<Utf16>, Int32, Int32, Pointer<Void>, Int32, Int32, Pointer<Void>);
typedef _CreateFileWDart = Pointer<Void> Function(
    Pointer<Utf16>, int, int, Pointer<Void>, int, int, Pointer<Void>);
final _CreateFileWDart _createFileW =
    _kernel32.lookupFunction<_CreateFileWNative, _CreateFileWDart>(
        'CreateFileW');

typedef _GetFileTimeNative = Int32 Function(
    Pointer<Void>, Pointer<Void>, Pointer<Void>, Pointer<Void>);
typedef _GetFileTimeDart = int Function(
    Pointer<Void>, Pointer<Void>, Pointer<Void>, Pointer<Void>);
final _GetFileTimeDart _getFileTime =
    _kernel32.lookupFunction<_GetFileTimeNative, _GetFileTimeDart>(
        'GetFileTime');

typedef _CloseHandleNative = Int32 Function(Pointer<Void>);
typedef _CloseHandleDart = int Function(Pointer<Void>);
final _CloseHandleDart _closeHandle =
    _kernel32.lookupFunction<_CloseHandleNative, _CloseHandleDart>(
        'CloseHandle');

/// 获取目录创建时间 (Windows 专用)。
/// dart:io 的 FileStat 无创建时间, 用 CreateFileW + GetFileTime 读取。
/// 失败返回 null。
DateTime? directoryCreationTime(String path) {
  final handle = _createFileW(
    path.toNativeUtf16(),
    0, // GENERIC_READ
    0,
    nullptr,
    3, // OPEN_EXISTING
    0x02000000, // FILE_FLAG_BACKUP_SEMANTICS (允许打开目录)
    nullptr,
  );
  if (handle == nullptr ||
      handle.address == -1) {
    return null;
  }
  try {
    final ft = calloc<Uint64>(1);
    try {
      if (_getFileTime(handle, nullptr, nullptr, ft.cast()) == 0) {
        return null;
      }
      // FILETIME: 1601-01-01 起 100ns 计数 → Unix 微秒
      final micros = ft.value ~/ 10 - 11644473600000000;
      return DateTime.fromMicrosecondsSinceEpoch(micros);
    } finally {
      calloc.free(ft);
    }
  } finally {
    _closeHandle(handle);
  }
}
