import 'package:again/services/ui/presentation/filter/category/category_notifier.dart';
import 'package:again/services/ui/presentation/filter/category/category_state.dart';
import 'package:again/services/ui/presentation/filter/cv/cv_notifier.dart';
import 'package:again/services/ui/presentation/filter/cv/cv_state.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_notifier.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/presentation/misc_state/misc_notifier.dart';
import 'package:again/services/ui/presentation/misc_state/misc_state.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_notifier.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:again/services/ui/presentation/voice_work/voice_work_notifier.dart';
import 'package:again/services/ui/presentation/voice_work/voice_work_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cvProvider = NotifierProvider<CvNotifier, CvState>(CvNotifier.new);

final categoryProvider =
    NotifierProvider<CategoryNotifier, CategoryState>(CategoryNotifier.new);

final sortOrderProvider =
    NotifierProvider<SortOrderNotifier, SortOrderState>(SortOrderNotifier.new);

final voiceWorkProvider =
    NotifierProvider<VoiceWorkNotifier, VoiceWorkState>(VoiceWorkNotifier.new);

final voiceItemProvider =
    NotifierProvider<VoiceItemNotifier, VoiceItemState>(VoiceItemNotifier.new);

final miscUIProvider =
    NotifierProvider<MiscNotifier, MiscState>(MiscNotifier.new);

/// 歌词面板当前进度 (0 = 完全关闭/屏幕外, 1 = 全开)。
/// 拖动中由手势 (播放器/面板) 更新, 动画中由 AnimationController 驱动。
final lyricPanelProgressProvider = StateProvider<double>((ref) => 0.0);

/// 歌词面板动画请求: 非 null 时 ListLyricSwitch 从当前进度动画到该目标。
final lyricPanelAnimateRequestProvider =
    StateProvider<double?>((ref) => null);

/// 列表面板当前页 (0=作品, 1=音轨); 外部(如歌词界面队列按钮)可请求跳页。
final listsPanelPageProvider = StateProvider<int>((ref) => 0);

final uiServiceProvider = Provider<UIService>((ref) => UIService(ref));

final isSelectedFilterPlaying = Provider<bool>(
  (ref) =>
      ref.watch(
          sortOrderProvider.select((state) => state.isSelectedItemPlaying)) &&
      ref.watch(
          categoryProvider.select((state) => state.isSelectedItemPlaying)) &&
      ref.watch(cvProvider.select((state) => state.isSelectedItemPlaying)),
);

final isSelectedVoiceWorkPlaying = Provider<bool>(
  (ref) =>
      ref.watch(isSelectedFilterPlaying) &&
      ref.watch(
          voiceWorkProvider.select((state) => state.isSelectedItemPlaying)),
);
