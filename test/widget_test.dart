import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_calculator_app/main.dart';

void main() {
  testWidgets('calculator evaluates a simple expression with precedence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    Future<void> tap(String label) async {
      await tester.tap(find.byKey(Key('btn-$label')));
      await tester.pump();
    }

    await tap('2');
    await tap('+');
    await tap('3');
    await tap('×');
    await tap('4');
    await tap('=');

    expect(
      tester.widget<Text>(find.byKey(const Key('display'))).data,
      '14',
    );
  });

  testWidgets('clear returns the display to 0', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.byKey(const Key('btn-7')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '7');

    await tester.tap(find.byKey(const Key('btn-C')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('display'))).data, '0');
  });
}
