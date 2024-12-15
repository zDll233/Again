import 'dart:io';

import 'package:again/services/database/db/database.dart';

class VoiceWork {
  String title;
  String sourceId;
  String directoryPath;
  String coverPath;
  String category;
  DateTime? createdAt;

  VoiceWork({
    required this.title,
    required this.sourceId,
    required this.directoryPath,
    required this.coverPath,
    required this.category,
    required this.createdAt,
  });

  bool get exist => Directory(directoryPath).existsSync();

  static VoiceWork vkData2Vk(TVoiceWorkData vkData) {
    return VoiceWork(
      title: vkData.title,
      sourceId: vkData.sourceId,
      directoryPath: vkData.directoryPath,
      coverPath: vkData.coverPath,
      category: vkData.category,
      createdAt: vkData.createdAt,
    );
  }

  static List<VoiceWork> vkDataList2VkList(List<TVoiceWorkData> vkDataList) {
    return vkDataList.map((vkData) => vkData2Vk(vkData)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VoiceWork &&
        other.title == title &&
        other.directoryPath == directoryPath &&
        other.category == category &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      directoryPath.hashCode ^
      category.hashCode ^
      createdAt.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'sourceId': sourceId,
      'directoryPath': directoryPath,
      'coverPath': coverPath,
      'category': category,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory VoiceWork.fromMap(Map<String, dynamic> map) {
    return VoiceWork(
      title: map['title'] ?? '',
      sourceId: map['sourceId'] ?? '',
      directoryPath: map['directoryPath'] ?? '',
      coverPath: map['coverPath'] ?? '',
      category: map['category'] ?? '',
      createdAt: map['createdAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  VoiceWork copyWith({
    String? title,
    String? sourceId,
    String? directoryPath,
    String? coverPath,
    String? category,
    DateTime? createdAt,
  }) {
    return VoiceWork(
      title: title ?? this.title,
      sourceId: sourceId ?? this.sourceId,
      directoryPath: directoryPath ?? this.directoryPath,
      coverPath: coverPath ?? this.coverPath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
