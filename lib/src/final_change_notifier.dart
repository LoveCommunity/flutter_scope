
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';

/// `FinalChangeNotifier` is a configuration simulate assignments
/// with `ChangeNotifier` and `States<ChangeNotifier>`.
/// 
/// ```dart
/// class Counter extends ChangeNotifier { ... }
/// 
/// ...
/// 
/// FlutterScope(
///   configure: [
///     FinalChangeNotifier<Counter>(
///       name: 'counter',
///       statesName: 'counterStates',
///       equal: (_) => Counter(),
///     ),
///   ],
///   child: Builder(
///     builder: (context) {
///       final myCounter = context.scope.get<Counter>(name: 'counter');
///       final myCounterStates = context.scope.getStates<Counter>(name: 'counterStates');
///       return ...;
///     },
///   ),
/// );
/// ```
/// 
/// Which simulates:
/// 
/// ```dart
/// void flutterScope() {
///   // create and exposed `ChangeNotifier` and `States` in current scope
///   final Counter counter = Counter();
///   final States<Counter> counterStates = changeNotifierToStates(counter);
///   
///   // resolve instances in current scope
///   final myCounter = counter;
///   final myCounterStates = counterStates;
/// }
/// ```
/// 
class FinalChangeNotifier<T extends ChangeNotifier> extends FinalStatesConvertible<T, T> {

  /// Assign `ChangeNotifier` and its `States`,
  /// then expose them in current scope.
  FinalChangeNotifier({
    super.name,
    required super.equal,
    bool dispose = true,
    super.lazy,
  }): super(
    statesName: name,
    statesEqual: _changeNotifierToStates,
    expose: null,
    dispose: _superDispose<T>(dispose),
  );
}

States<T> _changeNotifierToStates<T extends ChangeNotifier>(T notifier) {
  return States.from(_ChangeNotifierAsObservable(notifier));
}

DisposeValue<T>? _superDispose<T extends ChangeNotifier>(bool dispose) {
  return dispose 
    ? (value) => value.dispose()
    : null;
}

class _ChangeNotifierAsObservable<T extends ChangeNotifier> extends InstanceAsObservable<T, T> {

  const _ChangeNotifierAsObservable(super.instance);

  @override
  Disposable observe(OnData<T> onData) {
    onData(instance);
    void listener() => onData(instance);
    instance.addListener(listener);
    return Disposable(() {
      instance.removeListener(listener);
    });
  }
}