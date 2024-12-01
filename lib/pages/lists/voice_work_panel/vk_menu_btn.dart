import 'package:again/pages/components/popup_menu_on_pressed.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/ui/move_voice_work.dart';
import 'package:again/services/database/voice_updater.dart';
import 'package:again/models/voice_work.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VkMenuBtn extends ConsumerWidget {
  final VoiceWork voiceWork;
  const VkMenuBtn({
    required this.voiceWork,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () {
          final items = <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'copySourceId',
              child: Text(voiceWork.sourceId, locale: Locale('zh', 'CN')),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              padding: EdgeInsets.all(0),
              child: Row(children: [
                Icon(Icons.arrow_left_sharp),
                Expanded(child: Text('声优', locale: Locale('zh', 'CN')))
              ]),
              onTap: () {
                showPopupMenuOnPressed(
                  ref,
                  context,
                  VoiceUpdater.getCvList(voiceWork.title)
                      .map((cvName) => PopupMenuItem<String>(
                          value: cvName, child: Text(cvName)))
                      .toList(),
                  _selectCv,
                );
              },
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              padding: EdgeInsets.all(0),
              child: Row(children: [
                Icon(Icons.arrow_left_sharp),
                Expanded(child: Text('移动到分类', locale: Locale('zh', 'CN')))
              ]),
              onTap: () {
                showPopupMenuOnPressed(
                  ref,
                  context,
                  ref
                      .read(categoryProvider)
                      .values
                      .where(
                          (cate) => cate != 'All' && cate != voiceWork.category)
                      .map((cate) =>
                          PopupMenuItem<String>(value: cate, child: Text(cate)))
                      .toList(),
                  (context, value) => changeCategory(ref, voiceWork, value),
                );
              },
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('移至回收站', locale: Locale('zh', 'CN')),
            ),
          ];

          showPopupMenuOnPressed(ref, context, items, _onPopMenuSelected);
        },
        icon: Icon(Icons.more_vert));
  }

  void _onPopMenuSelected(WidgetRef ref, String value) {
    if (value == 'copySourceId') {
      if (VoiceUpdater.isSourceIdValid(voiceWork.sourceId)) {
        Clipboard.setData(ClipboardData(text: voiceWork.sourceId));
      }
    } else if (value == 'delete') {
      deleteVoiceWork(ref, voiceWork);
    }
  }

  void _selectCv(WidgetRef ref, String cvName) {
    final cvIndex = ref.read(cvProvider).values.indexOf(cvName);
    ref.read(cvProvider.notifier).onSelected(cvIndex);
    final uiService = ref.read(uiServiceProvider);
    uiService.scrollToIndex(uiService.cvScrollController, cvIndex);
  }
}
