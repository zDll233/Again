import 'package:again/common/const.dart';
import 'package:again/services/ui/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';

class SortOrderNotifier extends ListStateNotifier<SortOrderState, SortOrder> {
  @override
  SortOrderState build() {
    return SortOrderState();
  }

  /// 持久化当前排序到 config.json (读改写串行化, 防并发覆盖)。
  Future<void> _persist(SortOrder order) async {
    await ref
        .read(configJsonProvider)
        .mutate((config) => {...config, 'sortOrder': order.toString()});
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    int length = state.values.length;
    int temp = state.selectedIndex + 1;
    cacheSelectedIndexAndItem(temp < length ? temp : 0);
    await _persist(state.selectedItem);
    await ref.read(dbNotifierProvider).updateVwList();
    await ref.read(uiServiceProvider).filterSelected();
  }

  /// 菜单选择排序方式, 按新排序刷新作品列表。
  /// [persist] 为 false 时只应用不写 config.json (启动恢复时用)。
  Future<void> setSortOrder(SortOrder order, {bool persist = true}) async {
    cacheSelectedIndexAndItemByValue(order);
    if (persist) {
      await _persist(order);
    }
    await ref.read(dbNotifierProvider).updateVwList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
