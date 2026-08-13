import 'package:flutter/material.dart';

/// 三列面板的统一容器: 半透明圆角卡片 + 标题行。
class VoicePanel<T> extends StatelessWidget {
  final String title;
  final Widget listView;
  final Widget icon;
  final Function()? onIconBtnPressed;
  final Function()? onTextBtnPressed;

  const VoicePanel({
    super.key,
    required this.title,
    required this.listView,
    required this.icon,
    this.onIconBtnPressed,
    this.onTextBtnPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          SizedBox(
            height: 46.0,
            child: Row(
              children: [
                Expanded(
                  child: onTextBtnPressed != null
                      ? InkWell(
                          onTap: onTextBtnPressed,
                          borderRadius: BorderRadius.circular(8),
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
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.75),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: textTheme.titleSmall?.copyWith(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ),
                        ),
                ),
                if (onIconBtnPressed != null)
                  IconButton(
                    onPressed: onIconBtnPressed,
                    icon: icon,
                    tooltip: null,
                    iconSize: 18.0,
                  ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: scheme.surface.withValues(alpha: 0.35),
                child: listView,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
