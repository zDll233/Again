import 'package:again/services/ui/theme/text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 字体颜色选择对话框: 支持"色相跟随主题色" (只调饱和/明度) 或自定义色。
/// 返回 null 表示取消; 返回记录含 themeHue/sat/val/color。
typedef FontColorResult = ({
  bool themeHue,
  double sat,
  double val,
  Color color,
});

class FontColorDialog extends StatefulWidget {
  const FontColorDialog({
    super.key,
    required this.initial,
    required this.fallbackColor,
    required this.themeHueColor,
  });

  /// 当前设置 (null=未设置)。
  final ColorSetting? initial;

  /// 未设置时的默认色 (对话框初始展示)。
  final Color fallbackColor;

  /// 主题色 (取其色相, 需要无彩色的回退已由调用方处理)。
  final Color themeHueColor;

  @override
  State<FontColorDialog> createState() => _FontColorDialogState();
}

class _FontColorDialogState extends State<FontColorDialog> {
  late bool _themeHue;
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null && init.themeHue) {
      _themeHue = true;
      _hsv = HSVColor.fromColor(
        HSVColor.fromAHSV(1, HSVColor.fromColor(widget.themeHueColor).hue,
            init.sat, init.val)
            .toColor(),
      );
    } else if (init != null && init.color != null) {
      _themeHue = false;
      _hsv = HSVColor.fromColor(init.color!);
    } else {
      _themeHue = false;
      _hsv = HSVColor.fromColor(widget.fallbackColor);
    }
  }

  Color get _current => _hsv.toColor();

  /// 主题色相下的当前色 (忽略 hsv.hue, 用主题色相)。
  Color get _themeHueCurrent => HSVColor.fromAHSV(
        1,
        HSVColor.fromColor(widget.themeHueColor).hue,
        _hsv.saturation,
        _hsv.value,
      ).toColor();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = _themeHue ? _themeHueCurrent : _current;
    return AlertDialog(
      title: const Text('选择字体颜色'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('色相跟随主题'),
              subtitle: const Text('只用主题色相, 调整饱和度和明度'),
              value: _themeHue,
              onChanged: (v) => setState(() => _themeHue = v),
            ),
            const SizedBox(height: 8),
            if (_themeHue) ...[
              _SliderBar(
                label: '饱和度',
                value: _hsv.saturation,
                colors: [
                  HSVColor.fromAHSV(1, HSVColor.fromColor(widget.themeHueColor).hue, 0, 1).toColor(),
                  HSVColor.fromAHSV(1, HSVColor.fromColor(widget.themeHueColor).hue, 1, 1).toColor(),
                ],
                onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
              ),
              _SliderBar(
                label: '明度',
                value: _hsv.value,
                colors: [
                  HSVColor.fromAHSV(1, HSVColor.fromColor(widget.themeHueColor).hue, 1, 0).toColor(),
                  HSVColor.fromAHSV(1, HSVColor.fromColor(widget.themeHueColor).hue, 1, 1).toColor(),
                ],
                onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
              ),
            ] else ...[
              _SliderBar(
                label: '色相',
                value: _hsv.hue / 360,
                colors: [
                  for (var h = 0.0; h <= 360; h += 60)
                    HSVColor.fromAHSV(1, h, 1, 1).toColor(),
                ],
                onChanged: (v) => setState(() => _hsv = _hsv.withHue(v * 360)),
              ),
              _SliderBar(
                label: '饱和度',
                value: _hsv.saturation,
                colors: [
                  HSVColor.fromAHSV(1, _hsv.hue, 0, _hsv.value).toColor(),
                  HSVColor.fromAHSV(1, _hsv.hue, 1, _hsv.value).toColor(),
                ],
                onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
              ),
              _SliderBar(
                label: '明度',
                value: _hsv.value,
                colors: [
                  HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 0).toColor(),
                  HSVColor.fromAHSV(1, _hsv.hue, _hsv.saturation, 1).toColor(),
                ],
                onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
              ),
              const SizedBox(height: 12),
              _HexInput(current: current, onChanged: (c) => setState(() => _hsv = HSVColor.fromColor(c))),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: current,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '#${current.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            (
              themeHue: _themeHue,
              sat: _hsv.saturation,
              val: _hsv.value,
              color: current,
            ),
          ),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

class _SliderBar extends StatelessWidget {
  const _SliderBar({
    required this.label,
    required this.value,
    required this.colors,
    required this.onChanged,
  });

  final String label;
  final double value;
  final List<Color> colors;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 10,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                trackShape: _GradientTrackShape(colors),
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}

class _HexInput extends StatelessWidget {
  const _HexInput({required this.current, required this.onChanged});

  final Color current;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      onChanged: (v) {
        final cleaned = v.replaceAll('#', '').trim();
        if (cleaned.length == 6) {
          final value = int.tryParse(cleaned, radix: 16);
          if (value != null) onChanged(Color(0xFF000000 | value));
        }
      },
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: scheme.onSurface,
      ),
      decoration: InputDecoration(
        isDense: true,
        prefixText: '# ',
        labelText: '颜色值',
        hintText: 'RRGGBB',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
        LengthLimitingTextInputFormatter(6),
      ],
    );
  }
}

/// 渐变轨道: 轨道绘制为横向渐变色条。
class _GradientTrackShape extends SliderTrackShape {
  const _GradientTrackShape(this.colors);

  final List<Color> colors;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
        trackLeft, trackTop, parentBox.size.width, trackHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required Offset thumbCenter,
      Offset? secondaryOffset,
      bool isEnabled = false,
      bool isDiscrete = false,
      required TextDirection textDirection}) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        trackRect,
        Radius.circular(trackRect.height / 2),
      ),
      Paint()
        ..shader = LinearGradient(colors: colors).createShader(trackRect),
    );
  }
}
