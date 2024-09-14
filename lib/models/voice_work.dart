import 'package:again/repository/database/database.dart';

class VoiceWork {
  String title;
  String directoryPath;
  String coverPath;
  String category;
  DateTime? createdAt;

  VoiceWork({
    required this.title,
    required this.directoryPath,
    required this.coverPath,
    required this.category,
    required this.createdAt,
  });

  static VoiceWork vkData2Vk(TVoiceWorkData vkData) {
    return VoiceWork(
        title: vkData.title,
        directoryPath: vkData.directoryPath,
        coverPath: vkData.coverPath,
        category: vkData.category,
        createdAt: vkData.createdAt);
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
        other.coverPath == coverPath &&
        other.category == category &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      directoryPath.hashCode ^
      coverPath.hashCode ^
      category.hashCode ^
      createdAt.hashCode;
}
