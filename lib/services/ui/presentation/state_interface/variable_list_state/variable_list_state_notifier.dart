import 'package:again/services/ui/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state.dart';
import 'package:flutter/foundation.dart';

abstract class VariableListStateNotifier<
    State extends VariableListState<ValueType>,
    ValueType> extends ListStateNotifier<State, ValueType> {
  // playingValues
  void setPlayingValues(List<ValueType> newValues) {
    state = state.copyWith(playingValues: newValues) as State;
  }

  /// `values`通常不等于`playingValues`,该函数根据`newItem`在`playingValues`的位置更新playingIndex
  @override
  void setPlayingIndexByValue(ValueType? newItem) {
    setPlayingIndex(
        newItem != null ? state.playingValues.indexOf(newItem) : -1);
  }

  // cache

  /// cache playingState into `playingValues`, `playingIndex` and `cachedPlayingItem`
  @override
  void cachePlayingState() {
    cachePlayingValues();
    super.cachePlayingState();
  }

  @protected
  void cachePlayingValues() {
    setPlayingValues(state.values);
  }

  // restore
  @override
  void restorePlayingState() {
    restorePlayingValues();
    super.restorePlayingState();
  }

  @protected
  void restorePlayingValues() {
    setValues(state.playingValues);
  }

  /// clear `playingIndex`, `cachedPlayingItem` and `playingValues`
  @override
  void clearPlayingState() {
    super.clearPlayingState();
    setPlayingValues(const []);
  }
}
