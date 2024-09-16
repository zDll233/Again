import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseState {
  BaseState copyWith();
}

/// `SortOrder`, `Category`, `Cv` 正在播放的列表和选中的列表均为`values`
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
      values.isNotEmpty && playingIndex >= 0 && playingIndex < values.length;

  bool get isSelectedItemPlaying => isPlaying && playingIndex == selectedIndex;

  @override
  ListState<ValueType> copyWith({
    List<ValueType>? values,
    int? playingIndex,
    int? selectedIndex,
  });
}

/// `VoiceWork`和`VoiveItem`正在播放的列表可以不和选中列表`values`相同，故需要`playingValues`和`cachedPlayingItem`
abstract class VariableListState<ValueType> extends ListState<ValueType> {
  final List<ValueType> playingValues;
  final ValueType? cachedPlayingItem;
  VariableListState(
      {required this.playingValues,
      this.cachedPlayingItem,
      required super.values,
      required super.playingIndex,
      required super.selectedIndex});

  @override
  ValueType get playingItem => playingValues[playingIndex];

  @override
  bool get isPlaying => cachedPlayingItem != null && playingIndex >= 0;

  @override
  bool get isSelectedItemPlaying => isPlaying && playingIndex == selectedIndex;

  @override
  VariableListState<ValueType> copyWith({
    ValueType? cachedPlayingItem,
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

  void updateValues(List<ValueType> newValues) {
    state = state.copyWith(values: newValues) as State;
  }

  void clearValues() {
    state = state.copyWith(values: const []) as State;
  }

  void setPlayingIndex(int newIndex) {
    state = state.copyWith(playingIndex: newIndex) as State;
  }

  /// 该函数根据`newItem`在`values`的位置更新playingIndex
  void setPlayingIndexByValue(ValueType newItem) {
    setPlayingIndex(state.values.indexOf(newItem));
  }

  void setSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex) as State;
  }

  void setSelectedIndexByValue(ValueType newItem) {
    setSelectedIndex(state.values.indexOf(newItem));
  }

  void updateState(State newState) {
    state = newState;
  }

  void restorePlayingIndex() => setSelectedIndex(state.playingIndex);

  void restorePlayingState() => restorePlayingIndex();

  void cachePlayingIndex() => setPlayingIndex(state.selectedIndex);

  void cachePlayingState() => cachePlayingIndex();

  void clearPlayingState() => setPlayingIndex(-1);

  void removeItemInValues(ValueType value) {
    final newValues = state.values.toList()..remove(value);
    updateValues(newValues);
  }
}

abstract class VariableListStateNotifier<
    State extends VariableListState<ValueType>,
    ValueType> extends ListStateNotifier<State, ValueType> {
  void clearPlayingValues() {
    state = state.copyWith(playingValues: const []) as State;
  }

  void removeItemInPlayingValues(ValueType value) {
    final newValues = state.playingValues.toList()..remove(value);
    state = state.copyWith(playingValues: newValues) as State;
  }

  /// `values`通常不等于`playingValues`,该函数根据`newItem`在`playingValues`的位置更新playingIndex
  @override
  void setPlayingIndexByValue(ValueType newItem) {
    setPlayingIndex(state.playingValues.indexOf(newItem));
  }

  void setCachedPlayingItem(ValueType? newItem) {
    state = state.copyWith(cachedPlayingItem: newItem) as State;
  }

  void cachePlayingValues() {
    state = state.copyWith(playingValues: state.values) as State;
  }

  void cachePlayingItem() {
    setCachedPlayingItem(state.playingIndex >= 0 ? state.playingItem : null);
  }

  @override
  void cachePlayingState() {
    cachePlayingIndex();
    cachePlayingValues();
    cachePlayingItem();
  }

  void restorePlayingValues() {
    state = state.copyWith(values: state.playingValues) as State;
  }

  @override
  void restorePlayingState() {
    restorePlayingValues();
    restorePlayingIndex();
  }

  void updatePlayingIndexByCache() {
    if (state.cachedPlayingItem != null) {
      final index =
          state.playingValues.indexOf(state.cachedPlayingItem as ValueType);
      setPlayingIndex(index);
    } else {
      setPlayingIndex(-1);
    }
  }

  @override
  void clearPlayingState() {
    clearPlayingValues();
    setPlayingIndex(-1);
    setCachedPlayingItem(null);
  }
}
