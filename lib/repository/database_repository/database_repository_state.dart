import 'package:again/repository/database_repository/database/database.dart';
import 'package:again/presentation/state_interface.dart';

class DatabaseRepositoryState extends BaseState {
  final List<TVoiceWorkData> voiceWorkDataList;

  DatabaseRepositoryState({
    this.voiceWorkDataList = const [],
  });

  @override
  DatabaseRepositoryState copyWith({
    List<TVoiceWorkData>? voiceWorkDataList,
  }) {
    return DatabaseRepositoryState(
      voiceWorkDataList: voiceWorkDataList ?? this.voiceWorkDataList,
    );
  }
}
