import 'package:flutter/material.dart';

/// 空列表占位: 图标 + 提示文案。
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({
    super.key,
    this.icon = Icons.music_off_outlined,
    this.message = 'No items found',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: scheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
