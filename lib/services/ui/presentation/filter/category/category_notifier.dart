import 'package:again/services/ui/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/presentation/filter/category/category_state.dart';

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedIndexAndItem(selectedIndex);
    // 分类变化时刷新 CV 列表(跟随分类, 选中重置为 All)
    await ref.read(dbNotifierProvider).updateCvList(state.selectedItem);
    await ref.read(dbNotifierProvider).updateVwList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
