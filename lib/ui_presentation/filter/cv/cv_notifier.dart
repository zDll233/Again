import 'package:again/repository/repository_providers.dart';
import 'package:again/ui_presentation/filter/cv/cv_state.dart';
import 'package:again/ui_presentation/state_interface.dart';
import 'package:again/ui_presentation/u_i_service.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    ref.read(repositoryProvider.notifier).updateVkList();
    await UIService(ref).filterSelected();
  }
}
