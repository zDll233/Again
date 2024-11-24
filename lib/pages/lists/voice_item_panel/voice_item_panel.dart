import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/voice_item_panel/voice_item_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceItemPanel extends ConsumerWidget {
  const VoiceItemPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiService = ref.watch(uiServiceProvider);
    return VoicePanel(
      title:
          'VoiceItems(${ref.watch(voiceItemProvider.select((state) => state.values)).length})',
      listView: const VoiceItemListView(),
      icon: const Icon(Icons.location_searching),
      onIconBtnPressed: uiService.onLocateBtnPressed,
      onTextBtnPressed: uiService.revealInExplorerView,
    );
  }
}
