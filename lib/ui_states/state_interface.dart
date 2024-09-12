import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseState {
  BaseState copyWith();
}

abstract class ListState<ValueType> extends BaseState {
  final List<ValueType> values;
  final int playingIndex;
  final int selectedIndex;

  ListState({
    required this.values,
    required this.playingIndex,
    required this.selectedIndex,
  });

  ValueType get playingItem => values[playingIndex];
  ValueType get selectedItem => values[selectedIndex];

  bool get isPlaying =>
      playingIndex >= 0 &&
      playingIndex < values.length &&
      playingIndex == selectedIndex;

  @override
  ListState<ValueType> copyWith({
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}

/// `State`: state type. `ValueType`: state.values type
abstract class ListStateNotifier<State extends ListState<ValueType>, ValueType>
    extends Notifier<State> {
  void updateValues(List<ValueType> newValues) {
    state = state.copyWith(values: newValues) as State;
  }

  void updatePlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex) as State;
  }

  void updateSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex) as State;
  }

  void updateState(State newState) {
    state = newState;
  }

  Future<void> onSelected(int selectedIndex);
}
