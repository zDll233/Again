import 'package:again/repository/database/database.dart';
import 'package:again/ui_presentation/state_interface.dart';

class RepositoryState extends BaseState {
  final List<TVoiceWorkData> voiceWorkDataList;

  RepositoryState({
    this.voiceWorkDataList = const [],
  });

  @override
  RepositoryState copyWith({
    List<TVoiceWorkData>? voiceWorkDataList,
  }) {
    return RepositoryState(
      voiceWorkDataList: voiceWorkDataList ?? this.voiceWorkDataList,
    );
  }
}