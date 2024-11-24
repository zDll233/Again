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
