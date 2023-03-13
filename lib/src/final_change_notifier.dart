
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
  return States((setState) {
    setState(notifier);
    void listener() => setState(notifier);
    notifier.addListener(listener);
    return Disposable(() {
      notifier.removeListener(listener);
    });
  });
}

DisposeValue<T>? _superDispose<T extends ChangeNotifier>(bool dispose) {
  return dispose 
    ? (value) => value.dispose()
    : null;
}
