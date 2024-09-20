import 'dart:async';

import 'package:again/screens/components/future_list.dart';
import 'package:again/screens/components/voice_panel.dart';
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

class FutureVoiceItemListView extends ConsumerStatefulWidget {
  const FutureVoiceItemListView({super.key});

  @override
  ConsumerState<FutureVoiceItemListView> createState() =>
      _FutureVoiceItemListViewState();
}

class _FutureVoiceItemListViewState
    extends ConsumerState<FutureVoiceItemListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uiServiceProvider).scrollToPlayingIndex();
    });
  }

  Future<List> fetchItems(WidgetRef ref) async {
    ref.read(uiServiceProvider).viCompleter = Completer();
    return ref.watch(voiceItemProvider.select((state) => state.values));
  }

  @override
  Widget build(BuildContext context) {
    final uiService = ref.watch(uiServiceProvider);
    final playingIndex =
        ref.watch(voiceItemProvider.select((state) => state.playingIndex));
    final voiceWorkPlaying = ref.watch(isSelectedVoiceWorkPlaying);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      uiService.viCompleter.complete();
    });

    return FutureListView(
      future: fetchItems(ref),
      itemBuilder: (context, vi, index) {
        return ListTile(
          title: Text(vi.title),
          onTap: () => ref.read(voiceItemProvider.notifier).onSelected(index),
          selected: playingIndex == index && voiceWorkPlaying,
        );
      },
      itemScrollController: uiService.viScrollController,
    );
  }
}
