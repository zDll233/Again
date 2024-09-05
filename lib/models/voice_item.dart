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
}
