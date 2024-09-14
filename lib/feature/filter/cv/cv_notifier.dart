import 'package:again/feature/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/feature/filter/cv/cv_state.dart';
import 'package:again/feature/state_interface.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    ref.read(repositoryProvider.notifier).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
