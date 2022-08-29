
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';


class FinalChangeNotifier<T extends ChangeNotifier> extends FinalChangeNotifierBase<T> {

  FinalChangeNotifier({
    Object? name,
    required Equal<T> equal,
    bool dispose = true,
  }): super(
    name: name,
    equal: equal,
    dispose: dispose,
    late: false,
  );
}

class LateFinalChangeNotifier<T extends ChangeNotifier> extends FinalChangeNotifierBase<T> {

  LateFinalChangeNotifier({
    Object? name,
    required Equal<T> equal,
    bool dispose = true,
  }): super(
    name: name,
    equal: equal,
    dispose: dispose,
    late: true,
  );
}

class FinalChangeNotifierBase<T extends ChangeNotifier> extends FinalStatesConvertibleBase<T, T> {

  FinalChangeNotifierBase({
    required Object? name,
    required Equal<T> equal,
    required bool dispose,
    required bool late,
  }): super(
    name: name,
    equal: equal,
    statesName: name,
    statesEqual: _changeNotifierToStates,
    expose: null,
    dispose: _superDispose<T>(dispose),
    late: late,
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

ValueDispose<T>? _superDispose<T extends ChangeNotifier>(bool dispose) {
  return dispose 
    ? (value) => value.dispose()
    : null;
}
