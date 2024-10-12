import 'package:again/repository/repository_providers.dart';
import 'package:again/services/history/history_manager.dart';
import 'package:again/presentation/key_event/key_event_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Initialization extends ConsumerStatefulWidget {
  const Initialization({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<Initialization> createState() => _InitializationState();
}

class _InitializationState extends ConsumerState<Initialization> {
  late final KeyEventHandler _keyEventHandler;

  @override
  void initState() {
    super.initState();
    _keyEventHandler = KeyEventHandler(ref);
    HardwareKeyboard.instance.addHandler(_keyEventHandler.handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyEventHandler.handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(_initProvider);

    if (result.isLoading) {
      return const Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(),
        ),
      );
    } else if (result.hasError) {
      return const Text('Error initializing.');
    }

    return widget.child;
  }
}

final _initProvider = FutureProvider.autoDispose((ref) async {
  await ref.read(dbRepoProvider.notifier).initialize();
  await ref.read(historyManagerProvider).loadHistory();
});
