
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';

class FinalValueNotifier<T extends ValueNotifier<E>, E> extends FinalStatesConvertible<T, E> {

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