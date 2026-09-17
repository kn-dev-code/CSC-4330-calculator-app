import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calculator_engine.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final CalculatorEngine _engine = CalculatorEngine();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    setState(() => _engine.input(key));
  }

  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final label = event.logicalKey.keyLabel;
    if (RegExp(r'^\d$').hasMatch(label)) {
      _onKey(label);
      return KeyEventResult.handled;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.numpadDecimal:
      case LogicalKeyboardKey.period:
        _onKey('.');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.add:
      case LogicalKeyboardKey.numpadAdd:
        _onKey('+');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.minus:
      case LogicalKeyboardKey.numpadSubtract:
        _onKey('−');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.asterisk:
      case LogicalKeyboardKey.numpadMultiply:
        _onKey('×');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.slash:
      case LogicalKeyboardKey.numpadDivide:
        _onKey('÷');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
      case LogicalKeyboardKey.equal:
        _onKey('=');
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
      case LogicalKeyboardKey.delete:
        _onKey('C');
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(flex: 2, child: _Display(engine: _engine)),
                    const SizedBox(height: 16),
                    Expanded(flex: 5, child: _Keypad(onKey: _onKey)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Display extends StatelessWidget {
  const _Display({required this.engine});

  final CalculatorEngine engine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      liveRegion: true,
      label: 'Calculator display',
      value: engine.display,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (engine.expression.isNotEmpty)
                Text(
                  engine.expression,
                  key: const Key('expression'),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              FittedBox(
                alignment: Alignment.centerRight,
                fit: BoxFit.scaleDown,
                child: Text(
                  engine.display,
                  key: const Key('display'),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: engine.hasError
                        ? scheme.error
                        : scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _row(const ['C', '÷', '×', '−'])),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(child: _row(const ['7', '8', '9'])),
                    Expanded(child: _row(const ['4', '5', '6'])),
                    Expanded(child: _row(const ['1', '2', '3'])),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: _button('0')),
                          Expanded(child: _button('.')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _button('+')),
                    Expanded(flex: 3, child: _button('=')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(List<String> keys) {
    return Row(
      children: [for (final key in keys) Expanded(child: _button(key))],
    );
  }

  Widget _button(String key) {
    return _CalculatorButton(label: key, onPressed: () => onKey(key));
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = _styleFor(label, scheme);

    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.expand(
        child: FilledButton(
          key: Key('btn-$label'),
          onPressed: onPressed,
          style: style,
          child: FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: label == '=' ? 32 : 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _styleFor(String key, ColorScheme scheme) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );
    final Color background;
    final Color foreground;

    if (key == 'C') {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else if (key == '=') {
      background = scheme.primary;
      foreground = scheme.onPrimary;
    } else if (CalculatorEngine.operators.contains(key)) {
      background = scheme.secondaryContainer;
      foreground = scheme.onSecondaryContainer;
    } else {
      background = scheme.surfaceContainerHigh;
      foreground = scheme.onSurface;
    }

    return FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      shape: shape,
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
