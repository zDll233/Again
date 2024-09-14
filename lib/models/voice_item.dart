import 'package:again/database/database.dart';

class VoiceItem {
  String title;
  String filePath;
  String voiceWorkPath;

  VoiceItem({
    required this.title,
    required this.filePath,
    required this.voiceWorkPath,
  });

  static VoiceItem viData2Vi(TVoiceItemData viData) {
    return VoiceItem(
        title: viData.title,
        filePath: viData.filePath,
        voiceWorkPath: viData.voiceWorkPath);
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
        other.voiceWorkPath == voiceWorkPath;
  }

  @override
  int get hashCode =>
      title.hashCode ^ filePath.hashCode ^ voiceWorkPath.hashCode;
}
