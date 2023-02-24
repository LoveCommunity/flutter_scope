
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';
import 'package:meta/meta.dart';

import 'flutter_scope.dart';

abstract class StatesWidgetBase<T> extends StatefulWidget {
  const StatesWidgetBase({ 
    Key? key,
    this.states,
  }): super(key: key);

  final States<T>? states;

  @override
  StatesWidgetBaseState<StatesWidgetBase<T>, T> createState();
}

abstract class StatesWidgetBaseState<W extends StatesWidgetBase<T>, T> extends State<W> implements Observer<T> {

  @protected
  States<T>? states;
  @protected
  Disposable? observation;
  @protected
  States<T> resolveStates() => widget.states ?? context.scope.get();

  late final Equality<Observable<Object?>> _equality = context.scope.getOrNull()
    ?? deepObservableEquality;

  @override
  void initState() {
    super.initState();
    final newStates = resolveStates();
    startObserve(newStates);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) { // enabling hot reload
      final newStates = resolveStates();
      final statesChanged = !_equality.equals(states!.observable, newStates.observable);
      if (statesChanged) {
        stopObserve();
        startObserve(newStates);
      }
    }
  }

  @override
  void dispose() {
    stopObserve();
    super.dispose();
  }

  @protected
  void startObserve(States<T> newStates) {
    states = newStates;
    observation = newStates.observe(onData);
  }

  @protected
  void stopObserve() {
    observation?.dispose();
    observation = null;
    states = null;
  }
}

typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T state);

class StatesBuilder<T> extends StatesWidgetBase<T> {
  const StatesBuilder({ 
    Key? key,
    States<T>? states,
    required this.builder,
  }): super(
    key: key,
    states: states,
  );

  final StateWidgetBuilder<T> builder;

  @override
  _StatesBuilderState<T> createState() => _StatesBuilderState();
}

class _StatesBuilderState<T> extends StatesWidgetBaseState<StatesBuilder<T>, T> {

  T? _currentState;

  @override
  void onData(T data) {
    setState(() {
      _currentState = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _currentState is T, 
      'current state should be instance of {$T} in build phase.'
    );
    return widget.builder(context, _currentState as T);
  }
}

@experimental
typedef FlutterOnData<T> = void Function(BuildContext context, T data);

@experimental
class StatesListener<T> extends StatesWidgetBase<T> {
  const StatesListener({ 
    Key? key,
    States<T>? states,
    this.skipInitialState = true,
    required this.onData,
    required this.child,
  }) : super(
    key: key,
    states: states,
  );

  final bool skipInitialState;
  final FlutterOnData<T> onData;
  final Widget child;

  @override
  _StatesListenerState<T> createState() => _StatesListenerState();
}

class _StatesListenerState<T> extends StatesWidgetBaseState<StatesListener<T>, T> {

  @override
  void startObserve(States<T> newStates) {
    states = newStates;
    final observable = widget.skipInitialState
      ? newStates.skipFirst()
      : newStates.observable;
    observation = observable.observe(onData);
  }

  @override
  void onData(T data) {
    widget.onData(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}