import 'dart:async';

import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/components/future_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      uiService.viCompleter.complete();
    });

    return FutureListView(
      future: fetchItems(ref),
      itemBuilder: (context, vi, index) {
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_voiceItemSelectedProvider(index));
            return ListTile(
              title: Text(vi.title),
              onTap: () =>
                  ref.read(voiceItemProvider.notifier).onSelected(index),
              selected: selected,
            );
          },
        );
      },
      itemScrollController: uiService.viScrollController,
    );
  }
}

final _voiceItemSelectedProvider = Provider.family<bool, int>((ref, index) {
  final voiceWorkPlaying = ref.watch(isSelectedVoiceWorkPlaying);
  return index ==
          ref.watch(voiceItemProvider.select((state) => state.selectedIndex)) &&
      voiceWorkPlaying;
});
