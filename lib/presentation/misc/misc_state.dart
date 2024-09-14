import 'package:again/presentation/state_interface.dart';

class MiscState extends BaseState {
  final bool showLyricPanel;

  MiscState({
    this.showLyricPanel = false,
  });

  @override
  MiscState copyWith({
    bool? showLyricPanel,
  }) {
    return MiscState(
      showLyricPanel: showLyricPanel ?? this.showLyricPanel,
    );
  }
}
