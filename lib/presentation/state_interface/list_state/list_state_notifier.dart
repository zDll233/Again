import 'package:again/presentation/state_interface/list_state/list_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  /// cache playingState into `playingIndex`, `cachedPlayingItem`
  void cachePlayingState() {
    cachePlayingIndex();
    // 最后缓存playingItem
    cachePlayingItem();
  }

  @protected
  void cachePlayingIndex() => setPlayingIndex(state.selectedIndex);

  @protected
  void cachePlayingItem() => setCachedPlayingItem(state.cachedSelectedItem);

  /// `playingIndex`, `cachedPlayingItem`
  void restorePlayingState() {
    restorePlayingIndex();
    restoreCachedPlayingItem();
  }

  @protected
  void restorePlayingIndex() => setSelectedIndex(state.playingIndex);

  @protected
  void restoreCachedPlayingItem() =>
      setCachedSelectedItem(state.cachedPlayingItem);

  /// `playingIndex` = -1, `cachedPlayingItem` = null
  void clearPlayingState() {
    setPlayingIndex(-1);
    setCachedPlayingItem(null);
  }
}
