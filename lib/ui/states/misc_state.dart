import 'package:again/ui/states/state_interface.dart';

class MiscState extends BaseState {
  final bool showLrcPanel;

  MiscState({
    required this.showLrcPanel,
  });

  @override
  MiscState copyWith({
    bool? showLrcPanel,
  }) {
    return MiscState(
      showLrcPanel: showLrcPanel ?? this.showLrcPanel,
    );
  }
}
