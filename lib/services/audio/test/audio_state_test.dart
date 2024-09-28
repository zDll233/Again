import 'package:again/services/audio/audio_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';

class ProviderShareState extends StatelessWidget {
  const ProviderShareState({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer(builder: (context, ref, _) {
        final audio = ref.watch(audioProvider);

        return Column(
          children: [
            ElevatedButton(
              onPressed: () => ref.watch(audioProvider.notifier).setVolume(0),
              child: Text(audio.volume.toInt().toString()),
            ),
          ],
        );
      }),
    );
  }
}

void main() {
  testWidgets('audio state test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ProviderShareState()));

    expect(find.text('1'), findsOneWidget);

    // change the state and re-render
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
  });
}
