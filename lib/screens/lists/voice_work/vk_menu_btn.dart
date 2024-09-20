import 'package:again/presentation/u_i_providers.dart';
import 'package:again/services/move_voice_work.dart';
import 'package:again/screens/components/popup_menu_on_pressed.dart';
import 'package:again/services/voice_updater.dart';
import 'package:again/models/voice_work.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VkMenuBtn extends ConsumerWidget {
  final VoiceWork voiceWork;
  const VkMenuBtn({
    required this.voiceWork,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (BuildContext buttonContext) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () async {
            List<String> cvList = VoiceUpdater.getCvList(voiceWork.title);

            final items = <PopupMenuEntry<String>>[
              ...cvList.map((cvName) => PopupMenuItem<String>(
                    value: cvName,
                    child: Text(cvName),
                  )),
              const PopupMenuDivider(),
              ...ref
                  .read(categoryProvider)
                  .values
                  .where((cate) => cate != "All" && cate != voiceWork.category)
                  .map((cate) => PopupMenuItem<String>(
                        value: cate,
                        child: Text(cate),
                      )),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('移至回收站'),
              ),
            ];

            if (buttonContext.mounted) {
              showPopupMenuOnPressed(
                buttonContext,
                ref,
                items,
                _onPopMenuSelected,
              );
            }
          },
        );
      },
    );
  }

  void _onPopMenuSelected(WidgetRef ref, String value) {
    if (value == "delete") {
      deleteVoiceWork(ref, voiceWork);
    } else if (ref.read(cvProvider).values.contains(value)) {
      _selectCv(ref, value);
    } else if (ref.read(categoryProvider).values.contains(value)) {
      changeCategory(ref, voiceWork, value);
    }
  }

  void _selectCv(WidgetRef ref, String cvName) {
    final cvIndex = ref.read(cvProvider).values.indexOf(cvName);
    ref.read(cvProvider.notifier).onSelected(cvIndex);
    final uiService = ref.read(uiServiceProvider);
    uiService.scrollToIndex(uiService.cvScrollController, cvIndex);
  }
}
