import 'package:again/presentation/u_i_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowLryicButton extends ConsumerWidget {
  const ShowLryicButton({
    super.key,
    required this.iconSize,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyricPanel =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));
    return IconButton(
      key: const Key('lyric_button'),
      onPressed: ref.read(miscUIProvider.notifier).toggleShowLyricPanel,
      iconSize: iconSize,
      icon: showLyricPanel
          ? const Icon(Icons.arrow_drop_down)
          : const Icon(Icons.arrow_drop_up),
    );
  }
}
