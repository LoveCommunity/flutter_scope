
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';

class FinalChangeNotifier<T extends ChangeNotifier> extends FinalStatesConvertible<T, T> {

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