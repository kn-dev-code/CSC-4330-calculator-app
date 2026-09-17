import 'package:flutter_test/flutter_test.dart';
import 'package:simple_calculator_app/calculator_engine.dart';

void main() {
  late CalculatorEngine engine;

  setUp(() {
    engine = CalculatorEngine();
  });

  void tap(String keys) {
    for (final key in keys.split(' ')) {
      engine.input(key);
    }
  }

  test('starts at 0', () {
    expect(engine.display, '0');
    expect(engine.expression, isEmpty);
  });

  test('enters a multi-digit number', () {
    tap('1 2 3');
    expect(engine.display, '123');
  });

  test('ignores extra leading zeros', () {
    tap('0 0 5');
    expect(engine.display, '5');
  });

  test('adds two numbers', () {
    tap('2 + 3 =');
    expect(engine.display, '5');
    expect(engine.expression, '2 + 3 =');
  });

  test('respects multiplication before addition', () {
    tap('2 + 3 × 4 =');
    expect(engine.display, '14');
  });

  test('respects multiplication before subtraction', () {
    tap('1 0 − 2 × 3 =');
    expect(engine.display, '4');
  });

  test('evaluates equal-precedence multiply and divide left to right', () {
    tap('8 ÷ 2 × 4 =');
    expect(engine.display, '16');
  });

  test('divides then adds', () {
    tap('8 ÷ 2 + 2 =');
    expect(engine.display, '6');
  });

  test('chains addition', () {
    tap('1 + 2 + 3 =');
    expect(engine.display, '6');
  });

  test('handles decimals', () {
    tap('0 . 5 + 0 . 2 5 =');
    expect(engine.display, '0.75');
  });

  test('rejects a second decimal in the same number', () {
    tap('1 . 2 . 3');
    expect(engine.display, '1.23');
  });

  test('replaces the last operator when two are pressed in a row', () {
    tap('2 + × 3 =');
    expect(engine.display, '6');
  });

  test('drops a trailing operator instead of repeating the last number', () {
    tap('2 + =');
    expect(engine.display, '2');
  });

  test('shows Error on divide by zero', () {
    tap('8 ÷ 0 =');
    expect(engine.display, 'Error');
    expect(engine.hasError, isTrue);
  });

  test('clears after an error', () {
    tap('8 ÷ 0 = C');
    expect(engine.display, '0');
    expect(engine.hasError, isFalse);
  });

  test('starts a new calculation after tapping a digit on the result', () {
    tap('2 + 3 = 9');
    expect(engine.display, '9');
    expect(engine.expression, isEmpty);
  });

  test('continues from the result when an operator is pressed after equals', () {
    tap('2 + 3 = × 4 =');
    expect(engine.display, '20');
  });

  test('clear resets everything', () {
    tap('9 9 + 1 C');
    expect(engine.display, '0');
    expect(engine.expression, isEmpty);
  });

  test('formats whole-number results without a decimal', () {
    tap('4 ÷ 2 =');
    expect(engine.display, '2');
  });
}
