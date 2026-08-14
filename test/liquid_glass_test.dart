import 'package:again/pages/components/liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget build() {
    return MaterialApp(
      home: Scaffold(
        body: LiquidGlass(
          borderRadius: 12,
          child: const Text('内容'),
        ),
      ),
    );
  }

  testWidgets('LiquidGlass 渲染子内容与玻璃图层', (tester) async {
    await tester.pumpWidget(build());
    expect(find.text('内容'), findsOneWidget);
    expect(find.byType(ClipRRect), findsWidgets);
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
