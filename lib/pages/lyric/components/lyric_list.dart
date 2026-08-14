import 'package:again/pages/lyric/components/line_indicator.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// 歌词列表: 每行一个 InkWell 渲染 (Material 原生 hover/水波纹/内边距),
/// 点击行跳转播放, 当前行高亮并自动滚动居中。
class LyricList extends ConsumerStatefulWidget {
  final LyricsReaderModel model;

  const LyricList({super.key, required this.model});

  @override
  ConsumerState<LyricList> createState() => _LyricListState();
}

class _LyricListState extends ConsumerState<LyricList> {
  final ItemScrollController _itemScroll = ItemScrollController();
  int _currentIndex = 0;

  /// 用户手动滚动后的暂停跟随截止时间
  DateTime _pauseFollowUntil = DateTime.fromMillisecondsSinceEpoch(0);

  List<LyricsLineModel> get _lyrics => widget.model.lyrics;

  int _indexFor(Duration position) {
    final ms = position.inMilliseconds;
    var idx = 0;
    for (var i = 0; i < _lyrics.length; i++) {
      final t = _lyrics[i].startTime ?? 0;
      if (ms >= t) {
        idx = i;
      } else {
        break;
      }
    }
    return idx;
  }

  void _scrollToIndex(int index) {
    _itemScroll.scrollTo(
      index: index,
      alignment: 0.5,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final position =
        ref.watch(audioProvider.select((state) => state.position));
    final isPlaying = ref.watch(audioProvider.select((state) => state.isPlaying));
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    final lineColor = ts?.lyricColor?.resolve(
            scheme.onSurface.withValues(alpha: 0.55), themeHue) ??
        scheme.onSurface.withValues(alpha: 0.55);
    final highlightColor = ts?.lyricHighlightColor?.resolve(
            scheme.primary, themeHue) ??
        HSVColor.fromAHSV(1, themeHue.hue, 0.7, 0.9).toColor();

    final currentIndex = _indexFor(position);
    if (currentIndex != _currentIndex) {
      // 当前行变化: 更新高亮并自动滚动居中 (用户手动滚动后暂停 5 秒)
      _currentIndex = currentIndex;
      if (DateTime.now().isAfter(_pauseFollowUntil)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToIndex(_currentIndex);
        });
      }
    }

    final currentStartTime =
        Duration(milliseconds: _lyrics[_currentIndex].startTime ?? 0);

    return Column(
      children: [
        // 顶部指示条: 定位按钮 + 渐变引导线 + 时间戳
        LineIndicator(
          context: context,
          position: currentStartTime.inMilliseconds,
          flashBack: () {
            if (mounted) _scrollToIndex(_currentIndex);
          },
          confirmPlay: () {
            if (mounted) _scrollToIndex(_currentIndex);
          },
          isPlaying: isPlaying,
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _pauseFollowUntil =
                    DateTime.now().add(const Duration(seconds: 5));
              }
              return false;
            },
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScroll,
              itemCount: _lyrics.length,
              itemBuilder: (context, index) =>
                  _buildRow(index, currentIndex, ts, scheme, lineColor,
                      highlightColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    int index,
    int currentIndex,
    TextSettings? ts,
    ColorScheme scheme,
    Color lineColor,
    Color highlightColor,
  ) {
    final line = _lyrics[index];
    final isCurrent = index == currentIndex;
    final baseSize = ts?.lyricSize ?? 18;
    final gap = ts?.lyricLineGap ?? 25;
    final leftAlign = ts?.lyricAlign == 'left';
    final mainStyle = TextStyle(
      fontSize: isCurrent ? baseSize : baseSize - 2,
      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
      color: isCurrent ? highlightColor : lineColor,
      height: 1.4,
    );
    final extStyle = TextStyle(
      fontSize: isCurrent ? baseSize - 4 : baseSize - 6,
      color: (isCurrent ? highlightColor : lineColor)
          .withValues(alpha: 0.6),
      height: 1.3,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      // Material 风格 hover 覆盖层
      hoverColor: Colors.white.withValues(alpha: 0.08),
      splashColor: scheme.primary.withValues(alpha: 0.22),
      highlightColor: Colors.transparent,
      onTap: () {
        final startTime = Duration(milliseconds: line.startTime ?? 0);
        ref.read(audioProvider.notifier).seek(startTime);
        if (!isCurrent || !ref
            .read(audioProvider.select((s) => s.isPlaying))) {
          ref.read(audioProvider.notifier).resume();
        }
        // 立即滚动到该行并高亮
        final indexAt = _indexFor(startTime);
        _currentIndex = indexAt;
        _scrollToIndex(indexAt);
      },
      child: Padding(
        // 水平内边距 12: 框左/右边缘与歌词之间的留白; 垂直 lineGap/2 实现行距
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: gap / 2,
        ),
        child: Column(
          children: [
            Text(
              line.mainText ?? '',
              style: mainStyle,
              textAlign: leftAlign ? TextAlign.left : TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (line.hasExt)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  line.extText ?? '',
                  style: extStyle,
                  textAlign: leftAlign ? TextAlign.left : TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
