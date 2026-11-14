import 'dart:async';

import 'package:again/models/voice_work.dart';
import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/kana_romaji.dart';
import 'package:again/pages/components/image_thumbnail.dart';
import 'package:again/pages/lists/works_panel/vw_menu_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WorksListView extends ConsumerStatefulWidget {
  const WorksListView({super.key});

  @override
  ConsumerState<WorksListView> createState() => _WorksListViewState();
}

class _WorksListViewState extends ConsumerState<WorksListView> {
  static const _doubleTapWindow = Duration(milliseconds: 300);
  static const _tapMoveSlop = 18.0;

  /// 宽屏左右拖拽开关筛选面板的最小横向位移 (逻辑像素)。
  static const _filterDragThreshold = 48.0;

  String _query = '';
  int? _activePointer;
  Offset? _pointerDownPosition;
  bool _pointerMoved = false;
  DateTime? _lastTapTime;
  int? _lastTapIndex;
  Offset? _lastTapPosition;
  Offset? _panelSwipeStart;
  Offset? _panelSwipeEnd;

  void _handlePointerDown(PointerDownEvent event) {
    _activePointer = event.pointer;
    _pointerDownPosition = event.position;
    _pointerMoved = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_activePointer != event.pointer || _pointerDownPosition == null) {
      return;
    }
    if ((event.position - _pointerDownPosition!).distance > _tapMoveSlop) {
      _pointerMoved = true;
    }
  }

  void _handlePointerUp(int index, PointerUpEvent event) {
    if (_activePointer != event.pointer) return;
    final isTap = !_pointerMoved;
    _activePointer = null;
    _pointerDownPosition = null;
    _pointerMoved = false;
    if (!isTap) {
      _lastTapTime = null;
      _lastTapIndex = null;
      _lastTapPosition = null;
      return;
    }

    final now = DateTime.now();
    final isDoubleTap = _lastTapIndex == index &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) <= _doubleTapWindow &&
        _lastTapPosition != null &&
        (event.position - _lastTapPosition!).distance <= _tapMoveSlop;
    if (isDoubleTap) {
      _lastTapTime = null;
      _lastTapIndex = null;
      _lastTapPosition = null;
      if (mounted) {
        ref.read(listsPanelPageProvider.notifier).state = 1;
      }
    } else {
      unawaited(ref.read(voiceWorkProvider.notifier).onSelected(index));
      _lastTapTime = now;
      _lastTapIndex = index;
      _lastTapPosition = event.position;
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointer != event.pointer) return;
    _activePointer = null;
    _pointerDownPosition = null;
    _pointerMoved = false;
  }

  /// 过滤后保留原始 index, onSelected 需要原始 index。
  List<int> _filteredIndices(List<VoiceWork> values) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(values.length, (i) => i);
    }
    final indices = <int>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v.title.toLowerCase().contains(q) ||
          v.sourceId.toLowerCase().contains(q) ||
          kanaToRomaji(v.title).toLowerCase().contains(q)) {
        indices.add(i);
      }
    }
    return indices;
  }

  Widget _withPanelSwipe(Widget child) {
    // 窄屏 (移动端): 右划开筛选抽屉, 左划切到音轨面板。
    // 宽屏 (桌面): 音轨面板已并排显示, 左右拖拽只用来开关筛选面板 ——
    // 筛选面板从左侧展开, 所以右拖展开、左拖收起。
    final isWide = MediaQuery.sizeOf(context).width >= 600;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        _panelSwipeStart = details.globalPosition;
        _panelSwipeEnd = details.globalPosition;
      },
      onHorizontalDragUpdate: (details) {
        _panelSwipeEnd = details.globalPosition;
      },
      onHorizontalDragEnd: (_) => _onPanelSwipeEnd(isWide),
      child: child,
    );
  }

  /// 拖拽结束: 按「起点 → 终点」的真实位移判断方向。
  ///
  /// 不能累加 onHorizontalDragUpdate 的 delta: 水平拖拽识别器只上报 dx
  /// (`_getDeltaForDetails` 把 dy 置 0), 纵向分量恒为 0, 斜向判定永远不会
  /// 成立 —— 斜着拖一点都会被误判成横向手势。
  void _onPanelSwipeEnd(bool isWide) {
    final start = _panelSwipeStart;
    final end = _panelSwipeEnd;
    _panelSwipeStart = null;
    _panelSwipeEnd = null;
    if (start == null || end == null) return;
    final delta = end - start;
    // 斜拖不触发, 避免轻微偏斜被误判为相反方向。
    if (delta.dx.abs() <= delta.dy.abs() * 1.3) return;
    if (isWide) {
      if (delta.dx.abs() < _filterDragThreshold) return;
      ref.read(miscUIProvider.notifier).setFilterExpanded(delta.dx > 0);
      return;
    }
    if (delta.dx > 0) {
      ref.read(miscUIProvider.notifier).toggleFilterExpanded();
    } else {
      ref.read(listsPanelPageProvider.notifier).state = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(voiceWorkProvider.select((state) => state.values));
    if (values.isEmpty) {
      // 空列表也挂拖拽层, 保证面板空白时同样能拉出筛选
      return _withPanelSwipe(const EmptyState());
    }
    // 搜索关闭时直接显示全量列表 (与开启时共用条目构建)
    final searchEnabled = searchEnabledFor(ref, searchWorksEnabledProvider);
    // 窄屏底部留出悬浮胶囊空间 (内容可滚到胶囊上方);
    // 宽屏面板视口止于播放器顶部 (MyApp 已留出播放器高度), 无需垫底
    final bottomPad = MediaQuery.sizeOf(context).width < 600 ? 120.0 : 0.0;
    if (!searchEnabled) {
      return _withPanelSwipe(
        ScrollablePositionedList.builder(
          itemCount: values.length,
          itemBuilder: (context, index) => _buildItem(context, index),
          itemScrollController:
              ref.read(uiServiceProvider).worksScrollController,
          padding: EdgeInsets.only(bottom: bottomPad),
        ),
      );
    }
    final filtered = _filteredIndices(values);

    // 拖拽层只包列表本体, 不包搜索框: 在搜索框里横向拖动是在选文字,
    // 不能被当成开关筛选面板的手势。
    return Column(
      children: [
        SearchableHeader(
          title: '作品',
          query: _query,
          onQueryChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
          compact: true,
        ),
        Expanded(
          child: _withPanelSwipe(
            filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_outlined,
                    message: '没有匹配的作品',
                  )
                : ScrollablePositionedList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildItem(context, filtered[index]),
                    itemScrollController:
                        ref.read(uiServiceProvider).worksScrollController,
                    padding: EdgeInsets.only(bottom: bottomPad),
                  ),
          ),
        ),
      ],
    );
  }

  /// 单个作品条目 (index 为原始列表索引)。
  Widget _buildItem(BuildContext context, int index) {
    final values = ref.watch(voiceWorkProvider.select((state) => state.values));
    final voiceWork = values[index];
    return Consumer(
      builder: (_, WidgetRef ref, __) {
        final selected = ref.watch(_voiceWorkSelectedProvider(index));
        final ts = ref.watch(textSettingsProvider).valueOrNull;
        final ui = ref.watch(uiSettingsProvider).valueOrNull;
        final themeHue = resolveThemeHueSource(
            Theme.of(context).colorScheme, kDefaultThemeSeed);
        final scheme = Theme.of(context).colorScheme;
        // 自绘条目: ListTile 的 leading 有最大高度约束 (dense 48/普通 56),
        // 会压扁 75px 缩略图; 用 Row 布局保持真实 1:1 缩略图
        return Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: (event) => _handlePointerUp(index, event),
          onPointerCancel: _handlePointerCancel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // 业务由外层 Listener 立即处理, 这里仅保留 InkWell 的按压反馈。
              onTap: () {},
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ui?.listDensity == 'comfortable' ? 12.0 : 5.0,
                  horizontal: 10.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // 复刻 ListTile 的 selectedTileColor 高亮
                  color: selected
                      ? scheme.secondaryContainer.withValues(alpha: 0.20)
                      : Colors.transparent,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ImageThumbnail(
                      imagePath: voiceWork.coverPath,
                      imageWidth: 60,
                      imageHeight: 60,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            voiceWork.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: ts?.panelTextSize,
                              fontWeight:
                                  fontWeightFor(ts?.panelTextWeight ?? 400),
                              color: selected
                                  ? scheme.primary
                                  : ts?.panelTextColor
                                      ?.resolve(Colors.transparent, themeHue),
                            ),
                          ),
                          if (voiceWork.sourceId.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                voiceWork.sourceId,
                                style: TextStyle(
                                  fontSize: 11.0,
                                  // 选中项的 RJ 号跟随主题色
                                  color: selected
                                      ? scheme.primary
                                      : scheme.onSurface
                                          .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    VwMenuBtn(voiceWork: voiceWork),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final _voiceWorkSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
});
