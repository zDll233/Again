import 'package:flutter/material.dart';

/// 液态玻璃效果容器 (参考克制式毛玻璃: 轻透见底 + 1px 顶部亮边)。
///
/// 结构:
/// 1. 极淡的半透明着色 —— 背景 (系统级 acrylic 窗口效果) 清晰透出;
/// 2. 顶部 1px 亮边 + 底部 2px 极淡阴影 (玻璃的厚度收边);
/// 3. 内容层。
///
/// 注意: 不要用 BackdropFilter (Windows 透明窗口拿不到桌面背景);
/// 背景层用 Positioned.fill, 不要用 StackFit.expand (无限高度约束崩溃)。
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 12,
    this.tintAlpha = 0.14,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final double tintAlpha;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // 玻璃主体: 极淡着色, 让背后内容透出来。
          Positioned.fill(
            child: ColoredBox(
              color: scheme.surface.withValues(alpha: tintAlpha),
            ),
          ),
          // 顶部 1px 亮边 (玻璃受光的克制高光)。
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.32),
                      Colors.white.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 底部 2px 极淡阴影 (玻璃厚度收边)。
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (padding != null)
            Padding(padding: padding!, child: child)
          else
            child,
        ],
      ),
    );
  }
}
