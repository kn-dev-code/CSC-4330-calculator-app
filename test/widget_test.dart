import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_calculator_app/main.dart';

void main() {
  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(Key('btn-$label')));
    await tester.pump();
  }

  String displayOf(WidgetTester tester) {
    return tester.widget<Text>(find.byKey(const Key('display'))).data!;
  }

  testWidgets('passing tests', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.byKey(const Key('display')), findsOneWidget);
    expect(displayOf(tester), '0');

    await tap(tester, '2');
    await tap(tester, '+');
    await tap(tester, '2');
    await tap(tester, '=');

    expect(displayOf(tester), '4');
  });

  testWidgets('adds and clears', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tap(tester, '7');
    await tap(tester, '+');
    await tap(tester, '3');
    await tap(tester, '=');
    expect(displayOf(tester), '10');

    await tap(tester, 'C');
    expect(displayOf(tester), '0');
  });

  testWidgets('handles division by zero', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tap(tester, '8');
    await tap(tester, '÷');
    await tap(tester, '0');
    await tap(tester, '=');

    expect(displayOf(tester), 'Error');
  });

  testWidgets('calculator evaluates a simple expression with precedence', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tap(tester, '2');
    await tap(tester, '+');
    await tap(tester, '3');
    await tap(tester, '×');
    await tap(tester, '4');
    await tap(tester, '=');

    expect(displayOf(tester), '14');
  });
}
