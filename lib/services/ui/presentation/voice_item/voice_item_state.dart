import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/state_interface/variable_list_state/variable_list_state.dart';
import 'package:collection/collection.dart';

/// 音轨排序方式: 标题升/降序, 文件顺序 (数据库原始顺序) 升/降序。
enum VoiceItemSort {
  titleAsc,
  titleDesc,
  fileAsc,
  fileDesc,
}

extension VoiceItemSortExtension on VoiceItemSort {
  String get label => switch (this) {
        VoiceItemSort.titleAsc => '标题顺序',
        VoiceItemSort.titleDesc => '标题倒序',
        VoiceItemSort.fileAsc => '时间顺序',
        VoiceItemSort.fileDesc => '时间倒序',
      };

  /// 从 config 字符串恢复, 未知值回退标题升序。
  static VoiceItemSort fromString(String value) {
    return VoiceItemSort.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => VoiceItemSort.titleAsc,
    );
  }
}

/// 按排序方式排列音轨列表。基准必须是规范顺序 (数据库原始顺序),
/// 不能对已排好序的列表重复应用 — 尤其 [VoiceItemSort.fileDesc] 是纯反转,
/// 对已反转列表再应用会倒回正序。
List<VoiceItem> applyVoiceItemSort(List<VoiceItem> base, VoiceItemSort sort) {
  switch (sort) {
    case VoiceItemSort.titleAsc:
      base.sort((a, b) => compareNatural(a.title, b.title));
      return base;
    case VoiceItemSort.titleDesc:
      base.sort((a, b) => compareNatural(b.title, a.title));
      return base;
    case VoiceItemSort.fileAsc:
      return base;
    case VoiceItemSort.fileDesc:
      return base.reversed.toList();
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
