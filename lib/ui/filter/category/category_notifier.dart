import 'package:again/repository/repository_providers.dart';
import 'package:again/ui/filter/category/category_state.dart';
import 'package:again/ui/state_interface.dart';
import 'package:again/ui/u_i_service.dart';

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    ref.read(repositoryProvider.notifier).updateVkList();
    await UIService(ref).filterSelected();
  }
}