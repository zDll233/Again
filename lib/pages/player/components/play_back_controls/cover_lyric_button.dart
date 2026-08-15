import 'dart:io';

import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前播放作品封面缩略图按钮 (窄屏): 点击打开/收起歌词界面。
/// 无封面时显示音符占位。
class CoverLyricButton extends ConsumerWidget {
  const CoverLyricButton({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverPath = ref.watch(
        voiceWorkProvider.select((state) => state.cachedPlayingItem?.coverPath));
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          ref.read(miscUIProvider.notifier).toggleShowLyricPanel(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _hasCover(coverPath)
            ? Image.file(
                File(coverPath!),
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: (size * 3).round(),
                errorBuilder: (_, __, ___) => _placeholder(scheme),
              )
            : _placeholder(scheme),
      ),
    );
  }

  bool _hasCover(String? coverPath) =>
      coverPath != null && coverPath.isNotEmpty && File(coverPath).existsSync();

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      width: size,
      height: size,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Icon(
        Icons.music_note,
        size: size * 0.5,
        color: scheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
