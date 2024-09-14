import 'package:again/ui/misc/misc_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiscNotifier extends Notifier<MiscState> {
  @override
  MiscState build() {
    return MiscState();
  }

  void toggleShowLyricPanel() {
    state = state.copyWith(showLyricPanel: !state.showLyricPanel);
  }

  void hideLyricPanel() {
    state = state.copyWith(showLyricPanel: false);
  }

  void showLyricPanel() {
    state = state.copyWith(showLyricPanel: true);
  }
}

