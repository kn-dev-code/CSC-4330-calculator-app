class CalculatorEngine {
  static const operators = {'+', '−', '×', '÷'};
  static const _maxDigits = 12;

  final List<String> _parts = [];
  String _current = '0';
  bool _overwrite = true;
  bool _justEvaluated = false;
  String? _error;
  String _expression = '';

  String get display => _error ?? _current;
  String get expression => _expression;
  bool get hasError => _error != null;

  void input(String key) {
    if (_error != null && key != 'C') {
      clear();
    }

    if (key == 'C') {
      clear();
      return;
    }
    if (key == '=') {
      _equals();
      return;
    }
    if (operators.contains(key)) {
      _operator(key);
      return;
    }
    if (key == '.') {
      _decimal();
      return;
    }
    if (RegExp(r'^\d$').hasMatch(key)) {
      _digit(key);
    }
  }

  void clear() {
    _parts.clear();
    _current = '0';
    _overwrite = true;
    _justEvaluated = false;
    _error = null;
    _expression = '';
  }

  void _digit(String digit) {
    if (_justEvaluated) {
      _parts.clear();
      _expression = '';
      _justEvaluated = false;
      _overwrite = true;
    }

    if (_overwrite) {
      _current = digit;
      _overwrite = false;
    } else {
      if (_digitCount(_current) >= _maxDigits) {
        return;
      }
      if (_current == '0') {
        _current = digit;
      } else {
        _current += digit;
      }
    }
    _refreshExpression();
  }

  void _decimal() {
    if (_justEvaluated) {
      _parts.clear();
      _expression = '';
      _justEvaluated = false;
      _current = '0.';
      _overwrite = false;
      _refreshExpression();
      return;
    }

    if (_overwrite) {
      _current = '0.';
      _overwrite = false;
    } else if (!_current.contains('.')) {
      _current += '.';
    }
    _refreshExpression();
  }

  void _operator(String op) {
    if (_justEvaluated) {
      _parts
        ..clear()
        ..add(_current);
      _justEvaluated = false;
    } else if (!_overwrite || _parts.isEmpty) {
      _commitCurrent();
    }

    if (_parts.isEmpty) {
      _parts.add(_current);
    }

    if (operators.contains(_parts.last)) {
      _parts[_parts.length - 1] = op;
    } else {
      _parts.add(op);
    }

    _overwrite = true;
    _refreshExpression();
  }

  void _equals() {
    if (_justEvaluated) {
      return;
    }

    if (_parts.isNotEmpty && operators.contains(_parts.last) && _overwrite) {
      _parts.removeLast();
    } else {
      _commitCurrent();
    }
    if (_parts.isEmpty) {
      return;
    }
    if (operators.contains(_parts.last)) {
      _parts.removeLast();
    }
    if (_parts.length == 1) {
      _expression = '${_formatPart(_parts.single)} =';
      _justEvaluated = true;
      _overwrite = true;
      return;
    }

    try {
      final result = _evaluate(_parts);
      _expression = '${_parts.map(_formatPart).join(' ')} =';
      _current = _formatNumber(result);
      _parts
        ..clear()
        ..add(_current);
      _justEvaluated = true;
      _overwrite = true;
    } on _DivisionByZero {
      _error = 'Error';
      _expression = '';
      _parts.clear();
      _current = '0';
      _overwrite = true;
      _justEvaluated = false;
    }
  }

  void _commitCurrent() {
    if (_parts.isEmpty || operators.contains(_parts.last)) {
      _parts.add(_normalizeNumber(_current));
    } else if (_overwrite == false) {
      _parts[_parts.length - 1] = _normalizeNumber(_current);
    }
  }

  void _refreshExpression() {
    if (_parts.isEmpty) {
      _expression = '';
      return;
    }
    _expression = _parts.map(_formatPart).join(' ');
    if (operators.contains(_parts.last) && !_overwrite) {
      _expression = '$_expression $_current';
    }
  }

  static int _digitCount(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '').length;
  }

  static String _normalizeNumber(String value) {
    if (value.endsWith('.')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  static String _formatPart(String part) {
    if (operators.contains(part)) {
      return part;
    }
    final parsed = double.tryParse(part);
    if (parsed == null) {
      return part;
    }
    return _formatNumber(parsed);
  }

  static String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) {
      throw _DivisionByZero();
    }

    if (value.abs() >= 1e12 || (value.abs() < 1e-10 && value != 0)) {
      return value.toStringAsExponential(6);
    }

    final rounded = double.parse(value.toStringAsPrecision(12));
    if (rounded % 1 == 0 && rounded.abs() < 1e12) {
      return rounded.toInt().toString();
    }
    return rounded.toString();
  }

  static double _evaluate(List<String> parts) {
    final numbers = <double>[];
    final ops = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i.isEven) {
        numbers.add(double.parse(parts[i]));
      } else {
        ops.add(parts[i]);
      }
    }

    final reducedNumbers = <double>[numbers.first];
    final reducedOps = <String>[];
    for (var i = 0; i < ops.length; i++) {
      final op = ops[i];
      if (op == '×' || op == '÷') {
        final left = reducedNumbers.removeLast();
        final right = numbers[i + 1];
        if (op == '÷' && right == 0) {
          throw _DivisionByZero();
        }
        reducedNumbers.add(op == '×' ? left * right : left / right);
      } else {
        reducedNumbers.add(numbers[i + 1]);
        reducedOps.add(op);
      }
    }

    var result = reducedNumbers.first;
    for (var i = 0; i < reducedOps.length; i++) {
      if (reducedOps[i] == '+') {
        result += reducedNumbers[i + 1];
      } else {
        result -= reducedNumbers[i + 1];
      }
    }
    return result;
  }
}

class _DivisionByZero implements Exception {}
