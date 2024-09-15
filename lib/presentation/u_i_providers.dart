import 'package:again/presentation/filter/category/category_notifier.dart';
import 'package:again/presentation/filter/category/category_state.dart';
import 'package:again/presentation/filter/cv/cv_notifier.dart';
import 'package:again/presentation/filter/cv/cv_state.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_notifier.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/misc/misc_notifier.dart';
import 'package:again/presentation/misc/misc_state.dart';
import 'package:again/presentation/u_i_service.dart';
import 'package:again/presentation/voice_item/voice_item_notifier.dart';
import 'package:again/presentation/voice_item/voice_item_state.dart';
import 'package:again/presentation/voice_work/voice_work_notifier.dart';
import 'package:again/presentation/voice_work/voice_work_state.dart';
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

final uiServiceProvider = Provider((ref) => UIService(ref));
