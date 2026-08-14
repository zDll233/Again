import 'package:again/common/const.dart';
import 'package:again/pages/components/liquid_glass.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 三列面板的统一容器: 半透明圆角卡片 + 标题行。
/// 液态玻璃效果开启时, 列表区域使用 [LiquidGlass]。
class VoicePanel<T> extends ConsumerWidget {
  final String title;
  final Widget listView;
  final List<Widget> actions;

  const VoicePanel({
    super.key,
    required this.title,
    required this.listView,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    // 三种窗口效果统一使用 LiquidGlass 表面 (高亮细边 + 玻璃质感),
    // 毛玻璃模式着色更淡 (背景透出), 透明/不透明模式着色更深 (面板层次)。
    final effect =
        ref.watch(windowEffectProvider).valueOrNull ?? WINDOW_EFFECT_ACRYLIC;
    final tint = effect == WINDOW_EFFECT_ACRYLIC ? 0.14 : 0.35;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          SizedBox(
            height: 46.0,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: ts?.panelTitleSize,
                          color: ts?.panelTitleColor ??
                              scheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ),
                ),
                // 标题行按钮 (含排序菜单) 颜色与标题文字保持一致
                IconTheme(
                  data: IconThemeData(
                    color: scheme.onSurface.withValues(alpha: 0.75),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (final action in actions) action],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LiquidGlass(
              borderRadius: 12,
              tintAlpha: tint,
              // 硬裁剪: ScrollablePositionedList 定位滚动时内部会叠加渲染
              // 旧列表副本 (交叉淡入淡出), 此处兜底确保任何内容都出不了面板
              child: ClipRect(child: listView),
            ),
          ),
        ],
      ),
    );
  }
}
