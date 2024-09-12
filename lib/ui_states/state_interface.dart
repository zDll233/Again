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

  ValueType get playingItem;
  ValueType get selectedItem;

  @override
  ListState<ValueType> copyWith({
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}

/// `State`: state type. `ValueType`: state.values type
abstract class ListStateNotifier<State, ValueType> extends Notifier<State> {
  void updateValues(List<ValueType> newValues);
  void updatePlayingIndex(int newIndex);
  void updateSelectedIndex(int newIndex);
  void updateState(State newState);

  Future<void> onSelected(int selectedIndex);
}
