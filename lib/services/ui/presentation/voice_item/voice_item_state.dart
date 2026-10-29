import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state.dart';
import 'package:collection/collection.dart';

/// 音轨排序方式: 标题升/降序, 时间升/降序
/// (时间 = 音轨创建时间, 见 `lib/utils/file_time.dart`)。
enum VoiceItemSort {
  titleAsc,
  titleDesc,
  timeAsc,
  timeDesc,
}

extension VoiceItemSortExtension on VoiceItemSort {
  String get label => switch (this) {
        VoiceItemSort.titleAsc => '标题顺序',
        VoiceItemSort.titleDesc => '标题倒序',
        VoiceItemSort.timeAsc => '时间顺序',
        VoiceItemSort.timeDesc => '时间倒序',
      };

  /// 从 config 字符串恢复, 未知值回退标题升序。
  /// 兼容旧值: v4 之前叫 `fileAsc`/`fileDesc`。
  static VoiceItemSort fromString(String value) {
    final v = switch (value) {
      'VoiceItemSort.fileAsc' => 'VoiceItemSort.timeAsc',
      'VoiceItemSort.fileDesc' => 'VoiceItemSort.timeDesc',
      _ => value,
    };
    return VoiceItemSort.values.firstWhere(
      (e) => e.toString() == v,
      orElse: () => VoiceItemSort.titleAsc,
    );
  }
}

/// 时间排序: 按 [VoiceItem.createdAt] 升/降序。
/// drift 只存整秒, 同一秒内的音轨用标题自然序兜底, 保证顺序确定。
int _compareByTime(VoiceItem a, VoiceItem b) {
  final byTime = (a.createdAt ?? DateTime(1970))
      .compareTo(b.createdAt ?? DateTime(1970));
  if (byTime != 0) return byTime;
  return compareNatural(a.title, b.title);
}

/// 按排序方式排列音轨列表。四种排序都是全序, 重复应用结果不变。
List<VoiceItem> applyVoiceItemSort(List<VoiceItem> base, VoiceItemSort sort) {
  switch (sort) {
    case VoiceItemSort.titleAsc:
      base.sort((a, b) => compareNatural(a.title, b.title));
      return base;
    case VoiceItemSort.titleDesc:
      base.sort((a, b) => compareNatural(b.title, a.title));
      return base;
    case VoiceItemSort.timeAsc:
      base.sort(_compareByTime);
      return base;
    case VoiceItemSort.timeDesc:
      base.sort((a, b) => _compareByTime(b, a));
      return base;
  }
}

class VoiceItemState extends VariableListState<VoiceItem> {
  /// 当前音轨排序方式, 默认按标题升序。
  final VoiceItemSort sort;

  VoiceItemState({
    super.cachedPlayingItem,
    super.cachedSelectedItem,
    super.playingValues = const [],
    super.values = const [],
    super.playingIndex = -1,
    super.selectedIndex = -1,
    this.sort = VoiceItemSort.titleAsc,
  });

  @override
  VoiceItemState copyWith({
    VoiceItem? cachedPlayingItem,
    VoiceItem? cachedSelectedItem,
    List<VoiceItem>? playingValues,
    List<VoiceItem>? values,
    int? playingIndex,
    int? selectedIndex,
    VoiceItemSort? sort,
  }) {
    return VoiceItemState(
      cachedPlayingItem: cachedPlayingItem ?? this.cachedPlayingItem,
      cachedSelectedItem: cachedSelectedItem ?? this.cachedSelectedItem,
      playingValues: playingValues ?? this.playingValues,
      values: values ?? this.values,
      playingIndex: playingIndex ?? this.playingIndex,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      sort: sort ?? this.sort,
    );
  }

  String? get cachedPlayingVoiceItemPath => cachedPlayingItem?.filePath;

  String get selectedVoiceItemPath => selectedItem.filePath;
}
