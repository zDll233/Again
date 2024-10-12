import 'package:again/presentation/state_interface/base_state.dart';
import 'package:again/repository/database_repo/database/database.dart';

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
