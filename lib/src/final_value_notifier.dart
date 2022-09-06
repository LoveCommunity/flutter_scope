
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
  return States((setState) {
    setState(notifier.value);
    void listener() => setState(notifier.value);
    notifier.addListener(listener);
    return Disposable(() {
      notifier.removeListener(listener);
    });
  });
}

ValueDispose<T>? _superDispose<T extends ValueNotifier<E>, E>(bool dispose) {
  return dispose
    ? (value) => value.dispose()
    : null;
}
