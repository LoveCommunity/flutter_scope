
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
  return States((setState) {
    setState(notifier.value);
    void listener() => setState(notifier.value);
    notifier.addListener(listener);
    return Disposable(() {
      notifier.removeListener(listener);
    });
  });
}

DisposeValue<T>? _superDispose<T extends ValueNotifier<E>, E>(bool dispose) {
  return dispose
    ? (value) => value.dispose()
    : null;
}
