import 'package:again/ui_states/category_state.dart';
import 'package:again/ui_states/cv_state.dart';
import 'package:again/ui_states/sort_order_state.dart';
import 'package:again/ui_states/voice_item_state.dart';
import 'package:again/ui_states/voice_work_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UIService {
  final Ref ref;
  UIService(this.ref);

  bool get isFilterPlaying {
    final sortOrder = ref.read(sortOrderProvider);
    final category = ref.read(categoryProvider);
    final cv = ref.read(cvProvider);
    final voiceItem = ref.read(voiceItemProvider);

    return sortOrder.isPlaying &&
        category.isPlaying &&
        cv.isPlaying &&
        voiceItem.isPlaying;
  }

  bool get isVoiceWorkPlaying =>
      isFilterPlaying && ref.read(voiceWorkProvider).isPlaying;

  bool get isVoiceItemPlaying =>
      isVoiceWorkPlaying && ref.read(voiceItemProvider).isPlaying;

  Future<void> filterSelected() async {
    final voiceWorkNotifier = ref.read(voiceWorkProvider.notifier);

    if (isFilterPlaying) {
      await voiceWorkNotifier
          .onSelected(ref.read(voiceWorkProvider).playingIndex);
    } else {
      voiceWorkNotifier.updateSelectedIndex(-1);
      final voiceItemNotifier = ref.read(voiceItemProvider.notifier);
      voiceItemNotifier.clearValues();
    }
  }

  void setAllSelectedIndex2Playing() {
    ref.read(sortOrderProvider.notifier).setSelectedIndex2Playing();
    ref.read(categoryProvider.notifier).setSelectedIndex2Playing();
    ref.read(cvProvider.notifier).setSelectedIndex2Playing();
    ref.read(voiceWorkProvider.notifier).setSelectedIndex2Playing();
    ref.read(voiceItemProvider.notifier).setSelectedIndex2Playing();
  }
}
