import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/presentation/filter/category/category_state.dart';
import 'package:again/presentation/state_interface.dart';

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedItem(selectedIndex);
    await ref.read(repositoryProvider.notifier).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
