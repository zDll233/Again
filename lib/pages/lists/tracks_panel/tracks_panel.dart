import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/tracks_panel/tracks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksPanel extends ConsumerWidget {
  const TracksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiService = ref.watch(uiServiceProvider);
    return VoicePanel(
      title:
          '音轨(${ref.watch(voiceItemProvider.select((state) => state.values)).length})',
      listView: const TracksListView(),
      icon: const Icon(Icons.location_searching),
      onIconBtnPressed: uiService.onLocateBtnPressed,
      onTextBtnPressed: uiService.revealInExplorerView,
    );
  }
}
