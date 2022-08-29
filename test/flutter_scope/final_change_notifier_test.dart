
import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:dart_scope/dart_scope.dart';

void main() {

  test('`FinalChangeNotifierBase` is sync configuration', () {

    final scope = Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) => _MockChangeNotifier('a'),
        dispose: true,
        late: false,
      ),
    ]);

    expect(scope, isA<Scope>());

  });

  test('`FinalChangeNotifierBase` share same value and states in scope', () async {

    final scope = await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) => _MockChangeNotifier('a'),
        dispose: true,
        late: false,
      ),
    ]);

    final notifier1 = scope.get<_MockChangeNotifier>();
    final notifier2 = scope.get<_MockChangeNotifier>();
    final states1 = scope.get<States<_MockChangeNotifier>>();
    final states2 = scope.get<States<_MockChangeNotifier>>();

    final isNotifierIdentical = identical(notifier1, notifier2);
    final isStatesIdentical = identical(states1, states2);

    expect(isNotifierIdentical, true);
    expect(isStatesIdentical, true);

  });

  test('`FinalChangeNotifierBase` share same value and states in scope with name', () async {

    final scope = await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: 'notifier',
        equal: (_) => _MockChangeNotifier('a'),
        dispose: true,
        late: false,
      ),
    ]);

    final notifier1 = scope.get<_MockChangeNotifier>(name: 'notifier');
    final notifier2 = scope.get<_MockChangeNotifier>(name: 'notifier');
    final states1 = scope.get<States<_MockChangeNotifier>>(name: 'notifier');
    final states2 = scope.get<States<_MockChangeNotifier>>(name: 'notifier');

    final isNotifierIdentical = identical(notifier1, notifier2);
    final isStatesIdentical = identical(states1, states2);

    expect(isNotifierIdentical, true);
    expect(isStatesIdentical, true);

  });

  test('`FinalChangeNotifierBase` assign value which depends on other value', () async {

    final scope = await Scope.root([
      Configurable((scope) {
        scope.expose<int>(expose: () => 0);
      }),
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (scope) {
          final value = scope.get<int>().toString();
          return _MockChangeNotifier(value);
        },
        dispose: true,
        late: false,
      ),
    ]);

    final notifier = scope.get<_MockChangeNotifier>();
    expect(notifier.value, '0');

  });

  test('`FinalChangeNotifierBase` assign states success', () async {

    final scope = await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) => _MockChangeNotifier('a'),
        dispose: true,
        late: false,
      ),
    ]);

    final notifier = scope.get<_MockChangeNotifier>();
    final states = scope.get<States<_MockChangeNotifier>>();

    final List<String> recorded = [];

    final observation = states.observe((_notifier) {
      recorded.add(_notifier.value);
    });

    expect(recorded, [
      'a',
    ]);
    notifier.value = 'b';
    expect(recorded, [
      'a',
      'b',
    ]);
    
    observation.dispose();

  });

  test('`FinalChangeNotifierBase` will dispose notifier when `dispose` is true', () async {

    final scope = await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) => _MockChangeNotifier('a'),
        dispose: true,
        late: false,
      ),
    ]);

    final notifier = scope.get<_MockChangeNotifier>();

    expect(notifier.disposed, false);
    scope.dispose();
    expect(notifier.disposed, true);

  });

  test('`FinalChangeNotifierBase` will not dispose notifier when `dispose` is false', () async {

    final scope = await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) => _MockChangeNotifier('a'),
        dispose: false,
        late: false,
      ),
    ]);

    final notifier = scope.get<_MockChangeNotifier>();

    expect(notifier.disposed, false);
    scope.dispose();
    expect(notifier.disposed, false);

  });

  test('`FinalChangeNotifierBase` assign notifier immediately when `late` is false', () async {

    int invokes = 0;

    await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) {
          invokes += 1;
          return _MockChangeNotifier('a');
        },
        dispose: true,
        late: false,
      ),
    ]);
    
    expect(invokes, 1);

  });

  test('`FinalChangeNotifierBase` assign notifier lazily when `late` is true', () async {

    int invokes = 0;

    final scope = await Scope.root([
      FinalChangeNotifierBase<_MockChangeNotifier>(
        name: null,
        equal: (_) {
          invokes += 1;
          return _MockChangeNotifier('a');
        },
        dispose: true,
        late: true,
      ),
    ]);

    expect(invokes, 0);
    scope.get<_MockChangeNotifier>();
    expect(invokes, 1);
    
  });

  test('`FinalChangeNotifier` assign notifier immediately', () async {

    int invokes = 0;

    await Scope.root([
      FinalChangeNotifier<_MockChangeNotifier>(
        name: null,
        equal: (_) {
          invokes += 1;
          return _MockChangeNotifier('a');
        },
        dispose: true,
      ),
    ]);
    
    expect(invokes, 1);

  });
  
  test('`LateFinalChangeNotifier` assign notifier lazily', () async {

    int invokes = 0;

    final scope = await Scope.root([
      LateFinalChangeNotifier<_MockChangeNotifier>(
        name: null,
        equal: (_) {
          invokes += 1;
          return _MockChangeNotifier('a');
        },
        dispose: true,
      ),
    ]);

    expect(invokes, 0);
    scope.get<_MockChangeNotifier>();
    expect(invokes, 1);
  });
}

class _MockChangeNotifier extends ChangeNotifier {

  _MockChangeNotifier(this._value);

  String _value;
  bool _disposed = false;

  String get value => _value;
  set value(String newValue) {
    _value = newValue;
    notifyListeners();
  }

  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}