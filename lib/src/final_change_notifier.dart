
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';

class FinalChangeNotifier<T extends ChangeNotifier> extends FinalStatesConvertible<T, T> {

  FinalChangeNotifier({
    Object? name,
    required Equal<T> equal,
    bool dispose = true,
    bool lazy = true,
  }): super(
    name: name,
    equal: equal,
    statesName: name,
    statesEqual: _changeNotifierToStates,
    expose: null,
    dispose: _superDispose<T>(dispose),
    lazy: lazy,
  );
}

States<T> _changeNotifierToStates<T extends ChangeNotifier>(T notifier) {
  final observable = _ChangeNotifierAsObservable(instance: notifier);
  return States.from(observable);
}

DisposeValue<T>? _superDispose<T extends ChangeNotifier>(bool dispose) {
  return dispose 
    ? (value) => value.dispose()
    : null;
}

class _ChangeNotifierAsObservable<T extends ChangeNotifier> extends InstanceAsObservable<T, T> {
  const _ChangeNotifierAsObservable({
    required T instance,
  }): super(instance: instance);

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