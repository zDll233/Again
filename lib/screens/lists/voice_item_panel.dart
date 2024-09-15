import 'dart:async';

import 'package:again/components/future_list.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/presentation/u_i_providers.dart';
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
      listView: const FutureVoiceItemListView(),
      icon: const Icon(Icons.location_searching),
      onIconBtnPressed: uiService.onLocateBtnPressed,
      onTextBtnPressed: uiService.revealInExplorerView,
    );
  }
}

class FutureVoiceItemListView extends ConsumerWidget {
  const FutureVoiceItemListView({super.key});

  Future<List> fetchItems(WidgetRef ref) async {
    ref.watch(uiServiceProvider).viCompleter = Completer();
    return ref.watch(voiceItemProvider.select((state) => state.values));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiService = ref.watch(uiServiceProvider);
    final playingIndex =
        ref.watch(voiceItemProvider.select((state) => state.playingIndex));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      uiService.viCompleter.complete();
    });
    return FutureListView(
      future: fetchItems(ref),
      itemBuilder: (context, vi, index) {
        return ListTile(
          title: Text(vi.title),
          onTap: () => ref.read(voiceItemProvider.notifier).onSelected(index),
          selected: playingIndex == index && uiService.isVoiceItemPlaying,
        );
      },
      itemScrollController: uiService.viScrollController,
    );
  }
}
