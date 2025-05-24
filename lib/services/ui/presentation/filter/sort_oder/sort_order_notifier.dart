import 'package:again/services/ui/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';

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
    await ref.read(dbNotifierProvider).updateVwList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
