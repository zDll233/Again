import 'package:again/presentation/voice_work/voice_work_state.dart';
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
        final voiceWork = ref.watch(voiceWorkProvider);
        // final ui = ref.watch(uiProvider);

        return Column(
          children: [
            ElevatedButton(
              onPressed: () =>
                  ref.read(voiceWorkProvider.notifier).updatePlayingIndex(1),
              child: Text('${voiceWork.playingIndex}'),
            ),
            // Text('${ui.voiceWorkState.playingIndex}'),
          ],
        );
      }),
    );
  }
}

void main() {
  testWidgets('same state in multiple notifiers', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ProviderShareState()));

    // The default value is `-1`, as declared in our provider
    expect(find.text('-1'), findsNWidgets(1));
    expect(find.text('1'), findsNothing);

    // change the state and re-render
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // The state have properly changed
    expect(find.text('-1'), findsNothing);
    expect(find.text('1'), findsNWidgets(1));
  });
}
