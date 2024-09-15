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

abstract class VariableListState<ValueType> extends ListState<ValueType> {
  final List<ValueType> playingValues;
  VariableListState(
      {required this.playingValues,
      required super.values,
      required super.playingIndex,
      required super.selectedIndex});

  @override
  ValueType get playingItem => playingValues[playingIndex];

  @override
  VariableListState<ValueType> copyWith({
    List<ValueType>? playingValues,
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

  void clearValues() {
    state = state.copyWith(values: const []) as State;
  }

  void updatePlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex) as State;
  }

  void updatePlayingIndexByValue(ValueType newItem) {
    updatePlayingIndex(state.values.indexOf(newItem));
  }

  void updateSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex) as State;
  }

  void updateSelectedIndexByValue(ValueType newItem) {
    updateSelectedIndex(state.values.indexOf(newItem));
  }

  void updateState(State newState) {
    state = newState;
  }

  void restorePlayingIndex() => updateSelectedIndex(state.playingIndex);

  void cachePlayingIndex() => updatePlayingIndex(state.selectedIndex);

  void removeItemInValues(ValueType value) {
    final newValues = state.values.toList()..remove(value);
    updateValues(newValues);
  }

  Future<void> onSelected(int selectedIndex);
}

abstract class VariableListStateNotifier<
    State extends VariableListState<ValueType>,
    ValueType> extends ListStateNotifier<State, ValueType> {
  void cachePlayingValues() {
    state = state.copyWith(playingValues: state.values) as State;
  }

  void restorePlayingValues() {
    state = state.copyWith(values: state.playingValues) as State;
  }

  void clearPlayingValues() {
    state = state.copyWith(playingValues: const []) as State;
  }

  void removeItemInPlayingValues(ValueType value) {
    final newValues = state.playingValues.toList()..remove(value);
    state = state.copyWith(playingValues: newValues) as State;
  }
}
