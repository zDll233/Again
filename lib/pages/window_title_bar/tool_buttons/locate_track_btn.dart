import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 定位当前播放音轨 (标题栏)。
class LocateTrackBtn extends ConsumerWidget {
  const LocateTrackBtn({
    super.key,
    this.buttonWidth = 46.0,
    this.buttonHeight = 40.0,
  });

  final double buttonWidth;
  final double buttonHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: ref.read(uiServiceProvider).onLocateBtnPressed,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: buttonWidth,
        height: buttonHeight,
      ),
      tooltip: '定位到当前音轨',
      icon: const Icon(
        Icons.location_searching,
        color: Color.fromRGBO(255, 255, 255, 0.5),
      ),
    );
  }
}
