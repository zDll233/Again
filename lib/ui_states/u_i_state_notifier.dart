import 'package:again/ui_states/u_i_state.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:again/ui_states/category_state.dart';
import 'package:again/ui_states/cv_state.dart';
import 'package:again/ui_states/sort_order_state.dart';
import 'package:again/ui_states/voice_item_state.dart';
import 'package:again/ui_states/voice_work_state.dart';

class UINotifier extends Notifier<UIState> {
  @override
  UIState build() {
    Log.debug('UIState rebuilded.');
    return UIState(
      sortOrderState: ref.watch(sortOrderProvider),
      categoryState: ref.watch(categoryProvider),
      cvState: ref.watch(cvProvider),
      voiceWorkState: ref.watch(voiceWorkProvider),
      voiceItemState: ref.watch(voiceItemProvider),
      showLrcPanel: false,
    );
  }

  void toggleLrcPanel() {
    state = state.copyWith(showLrcPanel: !state.showLrcPanel);
  }
}

final uiProvider = NotifierProvider<UINotifier, UIState>(UINotifier.new);
