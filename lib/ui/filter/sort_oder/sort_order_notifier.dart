import 'package:again/repository/repository_providers.dart';
import 'package:again/ui/filter/sort_oder/sort_order_state.dart';
import 'package:again/ui/state_interface.dart';
import 'package:again/ui/u_i_service.dart';

class SortOrderNotifier extends ListStateNotifier<SortOrderState, SortOrder> {
  @override
  SortOrderState build() {
    return SortOrderState();
  }

  void updateSelectedSortOrder(SortOrder sortOrder) {
    int index = state.values.indexOf(sortOrder);
    updateSelectedIndex(index);
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    int length = state.values.length;
    int temp = state.selectedIndex + 1;
    updateSelectedIndex(temp < length ? temp : 0);
    ref.read(repositoryProvider.notifier).updateVkList();
    await UIService(ref).filterSelected();
  }
}
