import 'package:again/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/services/repository/repository_providers.dart';
import 'package:again/presentation/filter/category/category_state.dart';
import 'package:again/presentation/state_interface/state_interface.dart';

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedIndexAndItem(selectedIndex);
    await ref.read(dbRepoProvider.notifier).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
