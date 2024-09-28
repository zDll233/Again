import 'package:again/services/audio/audio_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LineIndicator extends StatelessWidget {
  const LineIndicator({
    super.key,
    required this.ref,
    required this.context,
    required this.position,
    required this.flashBack,
    required this.confirmPlay,
    required this.isPlaying,
  });

  final WidgetRef ref;
  final BuildContext context;
  final int position;
  final VoidCallback flashBack;
  final VoidCallback confirmPlay;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final audioNotifier = ref.read(audioProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: IconButton(
              onPressed: () {
                flashBack.call();
              },
              icon: const Icon(Icons.location_searching),
            ),
          ),
        ),
        Flexible(
          flex: 8,
          child: Container(
            decoration: const BoxDecoration(color: Colors.grey),
            height: 1,
            width: double.infinity,
          ),
        ),
        Flexible(
          flex: 1,
          child: TextButton(
            child: Text(
              Duration(milliseconds: position).toString().split('.').first,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              audioNotifier.seek(Duration(milliseconds: position));
              confirmPlay.call();
              if (!isPlaying) {
                audioNotifier.resume();
              }
            },
          ),
        ),
      ],
    );
  }
}
