import 'package:again/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/services/repository/repository_providers.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/state_interface/state_interface.dart';

class SortOrderNotifier extends ListStateNotifier<SortOrderState, SortOrder> {
  @override
  SortOrderState build() {
    return SortOrderState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    int length = state.values.length;
    int temp = state.selectedIndex + 1;
    cacheSelectedIndexAndItem(temp < length ? temp : 0);
    await ref.read(dbRepoProvider.notifier).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
