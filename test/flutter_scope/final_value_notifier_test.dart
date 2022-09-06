
import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:dart_scope/dart_scope.dart';

void main() {

  test('`FinalValueNotifier` is sync configuration', () {

    final scope = Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) => _MockValueNotifier('a'),
      ),
    ]);

    expect(scope, isA<Scope>());

  });

  test('`FinalValueNotifier` share same notifier and states in scope', () async {

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) => _MockValueNotifier('a'),
      ),
    ]);

    final notifier1 = scope.get<_MockValueNotifier>();
    final notifier2 = scope.get<_MockValueNotifier>();
    final states1 = scope.get<States<String>>();
    final states2 = scope.get<States<String>>();

    final isNotifierIdentical = identical(notifier1, notifier2);
    final isStatesIdentical = identical(states1, states2);

    expect(isNotifierIdentical, true);
    expect(isStatesIdentical, true);

  });

  test('`FinalValueNotifier` share same notifier and states in scope with name', () async {

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        name: 'notifier',
        equal: (_) => _MockValueNotifier('a'),
        statesName: 'states',
      ),
    ]);

    final notifier1 = scope.get<_MockValueNotifier>(name: 'notifier');
    final notifier2 = scope.get<_MockValueNotifier>(name: 'notifier');
    final states1 = scope.get<States<String>>(name: 'states');
    final states2 = scope.get<States<String>>(name: 'states');

    final isNotifierIdentical = identical(notifier1, notifier2);
    final isStatesIdentical = identical(states1, states2);

    expect(isNotifierIdentical, true);
    expect(isStatesIdentical, true);

  });

  test('`FinalValueNotifier` assign notifier which depends on other value', () async {

    final scope = await Scope.root([
      Configurable((scope) {
        scope.expose<int>(expose: () => 0);
      }),
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (scope) {
          final value = scope.get<int>().toString();
          return _MockValueNotifier(value);
        },
      ),
    ]);

    final notifier = scope.get<_MockValueNotifier>();
    expect(notifier.value, '0');

  });

  test('`FinalValueNotifier` assign states success', () async {

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) => _MockValueNotifier('a'),
      ),
    ]);

    final notifier = scope.get<_MockValueNotifier>();
    final states = scope.get<States<String>>();

    final List<String> recorded = [];

    final observation = states.observe(recorded.add);

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

  test('`FinalValueNotifier` will dispose notifier when `dispose` is omitted', () async {

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) => _MockValueNotifier('a'),
      ),
    ]);

    final notifier = scope.get<_MockValueNotifier>();

    expect(notifier.disposed, false);
    scope.dispose();
    expect(notifier.disposed, true);

  });

  test('`FinalValueNotifier` will dispose notifier when `dispose` is true', () async {

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) => _MockValueNotifier('a'),
        dispose: true,
      ),
    ]);

    final notifier = scope.get<_MockValueNotifier>();

    expect(notifier.disposed, false);
    scope.dispose();
    expect(notifier.disposed, true);

  });

  test('`FinalValueNotifier` will not dispose notifier when `dispose` is false', () async {

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) => _MockValueNotifier('a'),
        dispose: false,
      ),
    ]);

    final notifier = scope.get<_MockValueNotifier>();

    expect(notifier.disposed, false);
    scope.dispose();
    expect(notifier.disposed, false);

  });

  test('`FinalValueNotifier` assign notifier lazily when `lazy` is omitted', () async {

    int invokes = 0;

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) {
          invokes += 1;
          return _MockValueNotifier('a');
        },
      ),
    ]);

    expect(invokes, 0);
    scope.get<_MockValueNotifier>();
    expect(invokes, 1);

  });

  test('`FinalValueNotifier` assign notifier lazily when `lazy` is true', () async {

    int invokes = 0;

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) {
          invokes += 1;
          return _MockValueNotifier('a');
        },
        lazy: true,
      ),
    ]);

    expect(invokes, 0);
    scope.get<_MockValueNotifier>();
    expect(invokes, 1);

  });

  test('`FinalValueNotifier` assign notifier immediately when `lazy` is false', () async {
    
    int invokes = 0;

    final scope = await Scope.root([
      FinalValueNotifier<_MockValueNotifier, String>(
        equal: (_) {
          invokes += 1;
          return _MockValueNotifier('a');
        },
        lazy: false,
      ),
    ]);

    expect(invokes, 1);
    scope.get<_MockValueNotifier>();
    expect(invokes, 1);

  });
}

class _MockValueNotifier extends ValueNotifier<String> {

  _MockValueNotifier(String initialValue): super(initialValue);

  bool _disposed = false;
  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

