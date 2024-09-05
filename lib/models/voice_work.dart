import 'package:again/database/database.dart';

class VoiceWork {
  String? title;
  String? directoryPath;
  String? coverPath;
  String? category;
  DateTime? createdAt;

  VoiceWork({
    this.title,
    this.directoryPath,
    this.coverPath,
    this.category,
    this.createdAt,
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

  bool get hasDirectoryPath => directoryPath != null;
}
