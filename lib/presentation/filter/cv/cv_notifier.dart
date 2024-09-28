import 'package:again/presentation/state_interface/list_state/list_state_notifier.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/services/repository/repository_providers.dart';
import 'package:again/presentation/filter/cv/cv_state.dart';
import 'package:again/presentation/state_interface/state_interface.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    cacheSelectedIndexAndItem(selectedIndex);
    await ref.read(dbRepoProvider.notifier).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
