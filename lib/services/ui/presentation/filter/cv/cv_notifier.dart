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

  /// 作品菜单选择 CV: 先切换到作品所属分类, 再选中 CV。
  /// 分类变化会重建 CV 列表 (updateCvList), 因此必须等分类切换完成后再定位 CV。
  Future<void> selectFromVoiceWork(String cvName, String category) async {
    Clipboard.setData(ClipboardData(text: cvName));

    final categoryNotifier = ref.read(categoryProvider.notifier);
    final categoryIndex = ref.read(categoryProvider).values.indexOf(category);
    if (categoryIndex >= 0 &&
        categoryIndex != ref.read(categoryProvider).selectedIndex) {
      await categoryNotifier.onSelected(categoryIndex);
    }

    final cvIndex = state.values.indexOf(cvName);
    if (cvIndex < 0) return;
    await onSelected(cvIndex);
    final uiService = ref.read(uiServiceProvider);
    uiService.scrollToIndex(uiService.cvScrollController, cvIndex);
  }
}
