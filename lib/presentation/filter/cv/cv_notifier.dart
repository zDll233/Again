import 'package:again/database/database_providers.dart';
import 'package:again/presentation/filter/cv/cv_state.dart';
import 'package:again/presentation/state_interface.dart';
import 'package:again/presentation/u_i_service.dart';

class CvNotifier extends ListStateNotifier<CvState, String> {
  @override
  CvState build() {
    return CvState();
  }

  @override
  Future<void> onSelected(int selectedIndex) async {
    updateSelectedIndex(selectedIndex);
    ref.read(databaseProvider.notifier).updateVkList();
    await UIService(ref).filterSelected();
  }
}
