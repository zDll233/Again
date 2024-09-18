import 'package:again/repository/database_repository/database/database.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'filePath': filePath,
      'voiceWorkPath': voiceWorkPath,
    };
  }

  static VoiceItem fromMap(Map<String, dynamic> map) {
    return VoiceItem(
      title: map['title'],
      filePath: map['filePath'],
      voiceWorkPath: map['voiceWorkPath'],
    );
  }

  VoiceItem copyWith({
    String? title,
    String? filePath,
    String? voiceWorkPath,
  }) {
    return VoiceItem(
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      voiceWorkPath: voiceWorkPath ?? this.voiceWorkPath,
    );
  }
}
