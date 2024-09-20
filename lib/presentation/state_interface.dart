import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseState {
  BaseState copyWith();
}

/// `SortOrder`, `Category`, `Cv` 正在播放的列表和选中的列表均为`values`
abstract class ListState<ValueType> extends BaseState {
  final List<ValueType> values;
  final int playingIndex;
  final int selectedIndex;
  final ValueType? cachedPlayingItem;
  final ValueType? cachedSelectedItem;
  ListState({
    required this.cachedPlayingItem,
    required this.cachedSelectedItem,
    required this.values,
    required this.playingIndex,
    required this.selectedIndex,
  });

  @protected
  ValueType get playingItem => values[playingIndex];
  @protected
  ValueType get selectedItem => values[selectedIndex];

  bool get isPlayingIndexValid =>
      playingIndex >= 0 && playingIndex < values.length;

  bool get isSelectedIndexValid =>
      selectedIndex >= 0 && selectedIndex < values.length;

  bool get isPlaying => isPlayingIndexValid && cachedPlayingItem != null;

  bool get isSelectedItemPlaying =>
      isPlaying && cachedPlayingItem == cachedSelectedItem;

  @override
  ListState<ValueType> copyWith({
    ValueType? cachedPlayingItem,
    ValueType? cachedSelectedItem,
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}

/// `VoiceWork`和`VoiveItem`正在播放的列表可以不和选中列表`values`相同，故需要`playingValues`和`cachedPlayingItem`
abstract class VariableListState<ValueType> extends ListState<ValueType> {
  final List<ValueType> playingValues;
  VariableListState({
    required this.playingValues,
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    required super.values,
    required super.playingIndex,
    required super.selectedIndex,
  });

  @override
  ValueType get playingItem => playingValues[playingIndex];

  @override
  bool get isPlayingIndexValid =>
      playingIndex >= 0 && playingIndex < playingValues.length;

  @override
  bool get isPlaying => isPlayingIndexValid && cachedPlayingItem != null;

  @override
  bool get isSelectedItemPlaying =>
      isPlaying && cachedPlayingItem == cachedSelectedItem;

  @override
  VariableListState<ValueType> copyWith({
    ValueType? cachedPlayingItem,
    ValueType? cachedSelectedItem,
    List<ValueType>? playingValues,
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}

/// `State`: state type. `ValueType`: state.values type
abstract class ListStateNotifier<State extends ListState<ValueType>, ValueType>
    extends Notifier<State> {
  Future<void> onSelected(int selectedIndex);

  // values
  void setValues(List<ValueType> newValues) {
    state = state.copyWith(values: newValues) as State;
  }

  void clearValues() {
    state = state.copyWith(values: const []) as State;
  }

  // index
  @protected
  void setPlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex) as State;
  }

  /// 该函数根据`newItem`在`values`的位置更新playingIndex
  void setPlayingIndexByValue(ValueType? newItem) {
    setPlayingIndex(newItem != null ? state.values.indexOf(newItem) : -1);
  }

  @protected
  void setSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex) as State;
  }

  void setSelectedIndexByValue(ValueType? newItem) {
    setSelectedIndex(newItem != null ? state.values.indexOf(newItem) : -1);
  }

  // cachedPlayingItem
  @protected
  void setCachedPlayingItem(ValueType? newItem) {
    state = state.copyWith(cachedPlayingItem: newItem) as State;
  }

  // cachedSelectedItem
  @protected
  void setCachedSelectedItem(ValueType? newItem) {
    state = state.copyWith(cachedSelectedItem: newItem) as State;
  }

  void cacheSelectedIndexAndItem(int selectedIndex) {
    setSelectedIndex(selectedIndex);
    setCachedSelectedItem(
        state.isSelectedIndexValid ? state.selectedItem : null);
  }

  void cacheSelectedIndexAndItemByValue(ValueType newItem) {
    setSelectedIndexByValue(newItem);
    setCachedSelectedItem(
        state.isSelectedIndexValid ? state.selectedItem : null);
  }

  // cache: copy selected to playing
  void cachePlayingState() {
    cachePlayingIndex();
    // 最后缓存playingItem
    cachePlayingItem();
  }

  @protected
  void cachePlayingIndex() => setPlayingIndex(state.selectedIndex);
  @protected
  void cachePlayingItem() => setCachedPlayingItem(state.cachedSelectedItem);

  // restore: copy playing to selected
  void restorePlayingState() {
    restorePlayingIndex();
    restoreCachedPlayingItem();
  }

  @protected
  void restorePlayingIndex() => setSelectedIndex(state.playingIndex);
  @protected
  void restoreCachedPlayingItem() =>
      setCachedSelectedItem(state.cachedPlayingItem);

  // clear playing state
  void clearPlayingState() {
    setPlayingIndex(-1);
    setCachedPlayingItem(null);
  }
}

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
  @override
  void cachePlayingState() {
    cachePlayingIndex();
    cachePlayingValues();
    cachePlayingItem();
  }

  @protected
  void cachePlayingValues() {
    setPlayingValues(state.values);
  }

  // restore
  @override
  void restorePlayingState() {
    restorePlayingValues();
    restorePlayingIndex();
    restoreCachedPlayingItem();
  }

  @protected
  void restorePlayingValues() {
    setValues(state.playingValues);
  }

  @override
  void clearPlayingState() {
    super.clearPlayingState();
    setPlayingValues(const []);
  }
}
