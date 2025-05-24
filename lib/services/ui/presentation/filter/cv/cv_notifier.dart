import 'package:again/services/ui/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/presentation/filter/cv/cv_state.dart';
import 'package:flutter/services.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedIndexAndItem(selectedIndex);
    await ref.read(dbNotifierProvider).updateVwList();
    await ref.read(uiServiceProvider).filterSelected();
  }

  void onSelectedByName(String cvName) {
    Clipboard.setData(ClipboardData(text: cvName));
    final cvIndex = state.values.indexOf(cvName);
    onSelected(cvIndex);

    final uiService = ref.read(uiServiceProvider);
    uiService.scrollToIndex(uiService.cvScrollController, cvIndex);
  }
}
