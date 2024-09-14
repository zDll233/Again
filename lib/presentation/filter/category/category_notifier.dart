import 'package:again/database/database_providers.dart';
import 'package:again/presentation/filter/category/category_state.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';

class CategoryNotifier extends ListStateNotifier<CategoryState, String> {
  @override
  CategoryState build() {
    return CategoryState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    ref.read(databaseProvider.notifier).updateVkList();
    await UIService(ref).filterSelected();
  }
}