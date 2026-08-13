import 'package:again/services/ui/presentation/state_interface/base_state.dart';

class MiscState extends BaseState {
  final bool showLyricPanel;
  final bool filterExpanded;

  MiscState({
    this.showLyricPanel = false,
    this.filterExpanded = false,
  });

  @override
  MiscState copyWith({
    bool? showLyricPanel,
    bool? filterExpanded,
  }) {
    return MiscState(
      showLyricPanel: showLyricPanel ?? this.showLyricPanel,
      filterExpanded: filterExpanded ?? this.filterExpanded,
    );
  }
}
