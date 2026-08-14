import 'package:again/services/database/database_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 刷新音声库按钮 (标题栏)。
class RefreshBtn extends ConsumerStatefulWidget {
  const RefreshBtn({
    super.key,
    this.buttonWidth = 46.0,
    this.buttonHeight = 40.0,
  });

  final double buttonWidth;
  final double buttonHeight;

  @override
  ConsumerState<RefreshBtn> createState() => _RefreshBtnState();
}

class _RefreshBtnState extends ConsumerState<RefreshBtn> {
  bool _updating = false;

  Future<void> _onUpdatePressed() async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await ref.read(dbNotifierProvider).onUpdatePressed();
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _onUpdatePressed,
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: widget.buttonWidth,
        height: widget.buttonHeight,
      ),
      tooltip: '刷新音声库',
      icon: _updating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              Icons.refresh,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
    );
  }
}
