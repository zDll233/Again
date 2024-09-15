import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/lists/lists_view.dart';
import 'package:again/screens/lyric/lrc_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListLyricSwitch extends ConsumerWidget {
  const ListLyricSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLyricPanel =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));
    return Expanded(
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: showLyricPanel ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Offstage(
              offstage: showLyricPanel,
              child: const ListsView(),
            ),
          ),
          AnimatedOpacity(
            opacity: showLyricPanel ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Visibility(
              visible: showLyricPanel,
              child: const LyricPanel(),
            ),
          )
        ],
      ),
    );
  }
}
