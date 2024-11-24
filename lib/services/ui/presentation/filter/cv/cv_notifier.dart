import 'package:again/services/ui/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/services/ui/presentation/filter/cv/cv_state.dart';
import 'package:again/services/ui/presentation/state_interface/state_interface.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedIndexAndItem(selectedIndex);
    await ref.read(dbServiceProvider).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
