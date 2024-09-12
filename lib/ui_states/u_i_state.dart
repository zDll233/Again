import 'dart:async';

import 'package:again/ui_states/category_state.dart';
import 'package:again/ui_states/cv_state.dart';
import 'package:again/ui_states/sort_order_state.dart';
import 'package:again/ui_states/state_interface.dart';
import 'package:again/ui_states/voice_item_state.dart';
import 'package:again/ui_states/voice_work_state.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


class UIState extends BaseState {
  final SortOrderState sortOrderState;
  final CategoryState categoryState;
  final CvState cvState;

  final VoiceWorkState voiceWorkState;
  final VoiceItemState voiceItemState;

  final bool showLrcPanel;

  late Completer viCompleter;

  final cateScrollController = ItemScrollController();
  final cvScrollController = ItemScrollController();
  final vkScrollController = ItemScrollController();
  final viScrollController = ItemScrollController();

  UIState({
    required this.sortOrderState,
    required this.categoryState,
    required this.cvState,
    required this.voiceWorkState,
    required this.voiceItemState,
    required this.showLrcPanel,
    Completer? viCompleter, 
  }) {
    this.viCompleter = viCompleter ?? Completer();
  }

  @override
  UIState copyWith({
    SortOrderState? sortOrderState,
    CategoryState? categoryState,
    CvState? cvState,
    VoiceWorkState? voiceWorkState,
    VoiceItemState? voiceItemState,
    bool? showLrcPanel,
    Completer? viCompleter,
  }) {
    return UIState(
      sortOrderState: sortOrderState ?? this.sortOrderState,
      categoryState: categoryState ?? this.categoryState,
      cvState: cvState ?? this.cvState,
      voiceWorkState: voiceWorkState ?? this.voiceWorkState,
      voiceItemState: voiceItemState ?? this.voiceItemState,
      showLrcPanel: showLrcPanel ?? this.showLrcPanel,
      viCompleter: viCompleter ?? this.viCompleter,
    );
  }
}
