import 'package:again/services/ui/presentation/state_interface/base_state.dart';

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
