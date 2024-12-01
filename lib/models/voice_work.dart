import 'dart:io';

import 'package:again/services/database/db/database.dart';

class VoiceWork {
  String title;
  String rj;
  String directoryPath;
  String coverPath;
  String category;
  DateTime? createdAt;

  VoiceWork({
    required this.title,
    required this.rj,
    required this.directoryPath,
    required this.coverPath,
    required this.category,
    required this.createdAt,
  });

  bool get exist => Directory(directoryPath).existsSync();

  static VoiceWork vkData2Vk(TVoiceWorkData vkData) {
    return VoiceWork(
      title: vkData.title,
      rj: vkData.rj,
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
      'rj': rj,
      'directoryPath': directoryPath,
      'coverPath': coverPath,
      'category': category,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory VoiceWork.fromMap(Map<String, dynamic> map) {
    return VoiceWork(
      title: map['title'] ?? '',
      rj: map['rj'] ?? '',
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
    String? rj,
    String? directoryPath,
    String? coverPath,
    String? category,
    DateTime? createdAt,
  }) {
    return VoiceWork(
      title: title ?? this.title,
      rj: rj ?? this.rj,
      directoryPath: directoryPath ?? this.directoryPath,
      coverPath: coverPath ?? this.coverPath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  VoiceWork replaceCategory(String newCategory) {
    final newDirectoryPath = directoryPath.replaceFirst(category, newCategory);
    final newCoverPath = coverPath.replaceFirst(category, newCategory);
    return copyWith(
      directoryPath: newDirectoryPath,
      coverPath: newCoverPath,
      category: newCategory,
    );
  }
}
