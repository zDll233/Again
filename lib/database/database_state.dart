import 'package:again/database/database.dart';
import 'package:again/presentation/state_interface.dart';

class DatabaseState extends BaseState {
  final List<TVoiceWorkData> voiceWorkDataList;

  DatabaseState({
    this.voiceWorkDataList = const [],
  });

  @override
  DatabaseState copyWith({
    List<TVoiceWorkData>? voiceWorkDataList,
  }) {
    return DatabaseState(
      voiceWorkDataList: voiceWorkDataList ?? this.voiceWorkDataList,
    );
  }
}