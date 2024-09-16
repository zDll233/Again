import 'package:again/repository/repository_providers.dart';
import 'package:again/models/voice_work.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/voice_work/voice_work_state.dart';

class VoiceWorkNotifier
    extends VariableListStateNotifier<VoiceWorkState, VoiceWork> {
  @override
  VoiceWorkState build() {
    return VoiceWorkState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    if (selectedIndex < 0) return;

    setSelectedIndex(selectedIndex);

    ref.read(repositoryProvider.notifier).updateViList();
  }

  void addItemInPlayingValues(VoiceWork value) {
    List<VoiceWork> newValues = state.playingValues.toList()..add(value);
    ref.read(repositoryProvider.notifier).sortVoiceWorkList(newValues);
    state = state.copyWith(playingValues: newValues);
  }

  void setCachedSelectedItem(VoiceWork? newItem) {
    state = state.copyWith(cachedSelectedItem: newItem);
  }

  @override

  /// set selectedIndex and cache selectedItem
  void setSelectedIndex(int newIndex) {
    state = state.copyWith(selectedIndex: newIndex);
    _cacheSelectedItem();
  }

  @override
  void setSelectedIndexByValue(VoiceWork newItem) {
    setSelectedIndex(state.values.indexOf(newItem));
  }

  void _cacheSelectedItem() {
    setCachedSelectedItem(state.selectedIndex >= 0 ? state.selectedItem : null);
  }

  void _restoreCachedPlayingItem() {
    setCachedSelectedItem(state.cachedPlayingItem);
  }

  @override
  void restorePlayingState() {
    restorePlayingValues();
    restorePlayingIndex();
    _restoreCachedPlayingItem();
  }
}
