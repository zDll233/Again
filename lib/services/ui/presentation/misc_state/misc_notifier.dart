import 'dart:async';

import 'package:again/common/const.dart';
import 'package:again/services/ui/presentation/misc_state/misc_state.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiscNotifier extends Notifier<MiscState> {
  @override
  MiscState build() {
    return MiscState();
  }

  void toggleShowLyricPanel() {
    state = state.copyWith(showLyricPanel: !state.showLyricPanel);
  }

  void hideLyricPanel() {
    state = state.copyWith(showLyricPanel: false);
  }

  void showLyricPanel() {
    state = state.copyWith(showLyricPanel: true);
  }

  void toggleFilterExpanded() => setFilterExpanded(!state.filterExpanded);

  /// 展开/收起筛选面板, 并记住该状态 (config.json `filterExpanded`,
  /// 下次启动按记忆恢复)。
  ///
  /// [persist] 为 false 时只应用不写 config.json (启动恢复时用)。
  void setFilterExpanded(bool expanded, {bool persist = true}) {
    if (state.filterExpanded == expanded) return;
    state = state.copyWith(filterExpanded: expanded);
    if (persist) {
      unawaited(_persistFilterExpanded(expanded));
    }
  }

  Future<void> _persistFilterExpanded(bool expanded) async {
    try {
      await ref.read(configJsonProvider).mutate(
            (config) => {...config, 'filterExpanded': expanded},
          );
    } catch (error, stackTrace) {
      Log.error('Error persisting filterExpanded.\n$error.\n$stackTrace');
    }
  }
}
