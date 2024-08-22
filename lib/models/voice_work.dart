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

  bool get hasDirectoryPath => directoryPath != null;
}
