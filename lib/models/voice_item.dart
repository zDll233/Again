import 'dart:io';

import 'package:again/services/database/db/database.dart';

class VoiceItem {
  String title;
  String filePath;
  String voiceWorkPath;

  /// 音轨时间 (创建时间; 非 Windows 回退 mtime), 供「时间顺序/倒序」排序。
  /// 为兼容旧调用方允许为空 (为空时按 1970 参与排序)。
  DateTime? createdAt;

  VoiceItem({
    required this.title,
    required this.filePath,
    required this.voiceWorkPath,
    this.createdAt,
  });

  bool get exist => File(filePath).existsSync();

  static VoiceItem viData2Vi(TVoiceItemData viData) {
    return VoiceItem(
      title: viData.title,
      filePath: viData.filePath,
      voiceWorkPath: viData.voiceWorkPath,
      createdAt: viData.createdAt,
    );
  }

  static List<VoiceItem> viDataList2ViList(List<TVoiceItemData> viDataList) {
    return viDataList.map((viData) => viData2Vi(viData)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VoiceItem &&
        other.title == title &&
        other.filePath == filePath &&
        other.voiceWorkPath == voiceWorkPath &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      filePath.hashCode ^
      voiceWorkPath.hashCode ^
      createdAt.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'filePath': filePath,
      'voiceWorkPath': voiceWorkPath,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  static VoiceItem fromMap(Map<String, dynamic> map) {
    return VoiceItem(
      title: map['title'] ?? '',
      filePath: map['filePath'] ?? '',
      voiceWorkPath: map['voiceWorkPath'] ?? '',
      createdAt: map['createdAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  VoiceItem copyWith({
    String? title,
    String? filePath,
    String? voiceWorkPath,
    DateTime? createdAt,
  }) {
    return VoiceItem(
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      voiceWorkPath: voiceWorkPath ?? this.voiceWorkPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
