import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/presentation/filter/cv/cv_state.dart';
import 'package:again/presentation/state_interface.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    setSelectedIndex(selectedIndex);
    await ref.read(repositoryProvider.notifier).updateVkList();
    await ref.read(uiServiceProvider).filterSelected();
  }
}
