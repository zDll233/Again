import 'package:again/pages/settings/components/color_picker_dialog.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置页分区标题。
class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
      ),
    );
  }
}

/// 设置卡片容器 (圆角 + 子项间分隔线)。
class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 卡片间留间距, 独立模块视觉更清晰
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: scheme.onSurface.withValues(alpha: 0.06),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 分组/位置标题样式: 与「列表文字」同字号字重 (跟随设置), 颜色用中性 onSurface。
TextStyle textHeadingStyle(BuildContext context, TextSettings? ts) => TextStyle(
      fontSize: ts?.panelTextSize ?? 14,
      fontWeight: fontWeightFor(ts?.panelTextWeight ?? 400),
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
    );

/// 可折叠的文字设置分组 (默认展开); 标题跟随「列表文字」的字号/字重设置。
class SettingsTextGroup extends ConsumerWidget {
  final String title;
  final List<Widget> children;

  const SettingsTextGroup({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    return ExpansionTile(
      title: Text(title, style: textHeadingStyle(context, ts)),
      initiallyExpanded: true,
      tilePadding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 16),
      childrenPadding: EdgeInsets.only(left: isNarrow ? 0 : 20),
      // trailing 与重置按钮同构 (40px 容器 + 18px 图标), 右边缘精确对齐
      trailing: const SizedBox(
        width: 40,
        child: Icon(Icons.expand_more, size: 18),
      ),
      // 去掉 ExpansionTile 自带的分隔线/边框, 由外层卡片统一
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: Theme.of(context).colorScheme.onSurface,
      collapsedIconColor: Theme.of(context).colorScheme.onSurface,
      children: children,
    );
  }
}

/// 可折叠的文字位置分组 (嵌套在文字组内, 默认展开);
/// 标题与组标题同字体, 子选项行再缩进约两个字。
class SettingsTextPosition extends ConsumerWidget {
  final String title;
  final List<Widget> children;

  const SettingsTextPosition({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    return ExpansionTile(
      title: Text(title, style: textHeadingStyle(context, ts)),
      initiallyExpanded: true,
      tilePadding: EdgeInsets.only(
        left: isNarrow ? 20 : 28,
        right: isNarrow ? 8 : 16,
      ),
      // 子选项行缩进约两个字 (12px), 层级靠嵌套折叠呈现
      childrenPadding: const EdgeInsets.only(left: 12),
      trailing: const SizedBox(
        width: 40,
        child: Icon(Icons.expand_more, size: 18),
      ),
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: Theme.of(context).colorScheme.onSurface,
      collapsedIconColor: Theme.of(context).colorScheme.onSurface,
      children: children,
    );
  }
}

/// 小号"恢复默认"按钮。
class SettingsResetButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SettingsResetButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_backup_restore, size: 18),
      tooltip: '恢复默认',
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

/// 颜色圆点。
class SettingsColorSwatch extends StatelessWidget {
  final Color color;

  const SettingsColorSwatch({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

/// 字体大小设置行: 名称 + 滑杆 + 当前值 + 恢复默认。
class SettingsTextSizeTile extends StatelessWidget {
  final String label;
  final double value;
  final double defaultValue;
  final double min;
  final double max;
  final IconData icon;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangedEnd;
  final VoidCallback onReset;

  const SettingsTextSizeTile({
    super.key,
    required this.label,
    required this.value,
    required this.defaultValue,
    required this.onChanged,
    required this.onChangedEnd,
    required this.onReset,
    this.min = 10,
    this.max = 30,
    this.icon = Icons.format_size,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return ListTile(
      dense: true,
      // leading 占位与颜色行/主题区一致, 文字起点对齐
      leading: Icon(
        icon,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(label),
      contentPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              value.toStringAsFixed(0),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: isNarrow ? 96 : 120,
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              onChangeEnd: onChangedEnd,
            ),
          ),
          SettingsResetButton(onPressed: onReset),
        ],
      ),
    );
  }
}

/// 字体字重设置行: 常规/粗体 (400/700) 分段选择 + 恢复默认;
/// 微软雅黑只有 400/700 真实字重, 故不提供中间档。
class SettingsTextWeightTile extends StatelessWidget {
  final String label;
  final int value;
  final int defaultValue;
  final IconData icon;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangedEnd;
  final VoidCallback onReset;

  const SettingsTextWeightTile({
    super.key,
    required this.label,
    required this.value,
    required this.defaultValue,
    required this.onChanged,
    required this.onChangedEnd,
    required this.onReset,
    this.icon = Icons.format_bold,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(label),
      contentPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isNarrow ? 120 : 144,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 400, label: Text('常规')),
                ButtonSegment(value: 700, label: Text('粗体')),
              ],
              selected: {value},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
              onSelectionChanged: (selection) {
                final v = selection.first;
                onChanged(v);
                onChangedEnd(v);
              },
            ),
          ),
          SettingsResetButton(onPressed: onReset),
        ],
      ),
    );
  }
}

/// 字体颜色设置行: 色块 + 名称 + 恢复默认; 未设置时显示默认色并标注。
class SettingsTextColorTile extends StatelessWidget {
  final String label;
  final ColorSetting? setting;
  final Color fallback;
  final Color themeHueColor;
  final ValueChanged<ColorSetting?> onChanged;
  final VoidCallback onReset;
  final Future<void> Function(ColorSetting updated) onSave;

  const SettingsTextColorTile({
    super.key,
    required this.label,
    required this.setting,
    required this.fallback,
    required this.themeHueColor,
    required this.onChanged,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor =
        setting?.resolve(fallback, HSVColor.fromColor(themeHueColor)) ??
            fallback;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    return ListTile(
      dense: true,
      leading: SettingsColorSwatch(color: displayColor),
      title: Text(label),
      contentPadding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 16),
      subtitle: setting == null ? const Text('跟随主题') : null,
      trailing: SettingsResetButton(onPressed: onReset),
      onTap: () async {
        final result = await showDialog<ColorPickerResult>(
          context: context,
          builder: (context) => ColorPickerDialog(
            initial: setting?.color ?? fallback,
            fallbackColor: fallback,
            themeHueColor: themeHueColor,
            setting: setting,
          ),
        );
        if (result == null) return;
        final updated = result.themeHue
            ? ColorSetting(themeHue: true, sat: result.sat, val: result.val)
            : ColorSetting(color: result.color);
        onChanged(updated);
        await onSave(updated);
      },
    );
  }
}
