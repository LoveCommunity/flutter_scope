import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';

/// `FinalValueNotifier` is a configuration simulate assignments
/// with `ValueNotifier<E>` and `States<E>`.
/// 
/// ```dart
/// class Counter extends ValueNotifier<int> { ... }
/// 
/// ...
/// 
/// FlutterScope(
///   configure: [
///     FinalValueNotifier<Counter, int>(
///       name: 'counter',
///       statesName: 'counterStates',
///       equal: (_) => Counter(),
///     ),
///   ],
///   child: Builder(
///     builder: (context) {
///       final myCounter = context.scope.get<Counter>(name: 'counter');
///       final myCounterStates = context.scope.getStates<int>(name: 'counterStates');
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
///   // create and exposed `ValueNotifier` and `States` in current scope
///   final Counter counter = Counter();
///   final States<int> counterStates = valueNotifierToStates(counter); 
/// 
///   // resolve instances in current scope
///   final myCounter = counter;
///   final muCounterStates = counterStates;
/// }
/// ```
/// 
class FinalValueNotifier<T extends ValueNotifier<E>, E> extends FinalStatesConvertible<T, E> {

  /// Assign `ValueNotifier` and its `States`,
  /// then expose them in current scope.
  FinalValueNotifier({
    super.name,
    required super.equal,
    super.statesName,
    bool dispose = true,
    super.lazy,
  }): super(
    statesEqual: _valueNotifierToStates,
    dispose: _superDispose<T, E>(dispose),
  );
}

States<E> _valueNotifierToStates<T extends ValueNotifier<E>, E>(T notifier) {
  return States.from(_ValueNotifierAsObservable(notifier));
}

DisposeValue<T>? _superDispose<T extends ValueNotifier<E>, E>(bool dispose) {
  return dispose
    ? (value) => value.dispose()
    : null;
}

class _ValueNotifierAsObservable<T extends ValueNotifier<E>, E> extends InstanceAsObservable<T, E> {

  const _ValueNotifierAsObservable(super.instance);
  
  @override
  Disposable observe(OnData<E> onData) {
    onData(instance.value);
    void listener() => onData(instance.value);
    instance.addListener(listener);
    return Disposable(() {
      instance.removeListener(listener);
    });
  } 
}