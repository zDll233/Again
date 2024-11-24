import 'package:again/services/ui/presentation/state_interface/base_state.dart';
import 'package:again/services/ui/presentation/state_interface/state_interface.dart';

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
