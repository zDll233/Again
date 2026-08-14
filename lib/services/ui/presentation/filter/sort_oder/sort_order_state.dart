import 'package:again/services/ui/presentation/state_interface/list_state/list_state.dart';

enum SortOrder {
  byTitleAsc,
  byTitleDesc,
  byCreatedAtAsc,
  byCreatedAtDesc,
}

extension SortOrderExtension on SortOrder {
  static SortOrder fromString(String value) {
    // 兼容旧值 (SortOrder.byTitle / byCreatedAt): 回退到对应的升序
    final v = switch (value) {
      'SortOrder.byTitle' => SortOrder.byTitleAsc,
      'SortOrder.byCreatedAt' => SortOrder.byCreatedAtDesc,
      _ => value,
    };
    return SortOrder.values.firstWhere(
      (e) => e.toString() == v,
      orElse: () => SortOrder.byTitleAsc,
    );
  }

  String get label => switch (this) {
        SortOrder.byTitleAsc => '标题顺序',
        SortOrder.byTitleDesc => '标题倒序',
        SortOrder.byCreatedAtAsc => '时间顺序',
        SortOrder.byCreatedAtDesc => '时间倒序',
      };
}

class SortOrderState extends ListState<SortOrder> {
  SortOrderState({
    super.cachedPlayingItem = SortOrder.byTitleAsc,
    super.cachedSelectedItem = SortOrder.byTitleAsc,
    super.values = SortOrder.values,
    super.playingIndex = 0,
    super.selectedIndex = 0,
  });

  @override
  SortOrderState copyWith({
    SortOrder? cachedPlayingItem,
    SortOrder? cachedSelectedItem,
    List<SortOrder>? values,
    int? playingIndex,
    int? selectedIndex,
  }) {
    return SortOrderState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
