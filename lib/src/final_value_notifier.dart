
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';

class FinalValueNotifier<T extends ValueNotifier<E>, E> extends FinalStatesConvertible<T, E> {

  FinalValueNotifier({
    Object? name,
    required Equal<T> equal,
    Object? statesName,
    bool dispose = true,
    bool lazy = true,
  }): super(
    name: name,
    equal: equal,
    statesName: statesName,
    statesEqual: _valueNotifierToStates,
    dispose: _superDispose<T, E>(dispose),
    lazy: lazy,
  );
}

States<E> _valueNotifierToStates<T extends ValueNotifier<E>, E>(T notifier) {
  final observable = _ValueNotifierAsObservable<T, E>(instance: notifier);
  return States.from(observable);
}

DisposeValue<T>? _superDispose<T extends ValueNotifier<E>, E>(bool dispose) {
  return dispose
    ? (value) => value.dispose()
    : null;
}

class _ValueNotifierAsObservable<T extends ValueNotifier<E>, E> extends InstanceAsObservable<T, E> {
  const _ValueNotifierAsObservable({
    required T instance,
  }): super(instance: instance);

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