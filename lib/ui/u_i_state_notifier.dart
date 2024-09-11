import 'package:again/ui/u_i_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:again/ui/states/category_state.dart';
import 'package:again/ui/states/cv_state.dart';
import 'package:again/ui/states/sort_order_state.dart';
import 'package:again/ui/states/voice_item_state.dart';
import 'package:again/ui/states/voice_work_state.dart';

class UINotifier extends Notifier<UIState> {
  @override
  UIState build() {
    return UIState(
      sortOrderState: SortOrderState(),
      categoryState: CategoryState(),
      cvState: CvState(),
      voiceWorkState: VoiceWorkState(),
      voiceItemState: VoiceItemState(),
      showLrcPanel: false,
    );
  }

  void toggleLrcPanel() {
    state = state.copyWith(showLrcPanel: !state.showLrcPanel);
  }
}

final uiProvider = NotifierProvider<UINotifier, UIState>(UINotifier.new);
