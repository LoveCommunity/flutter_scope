
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'flutter_scope.dart';
import 'observable_equality.dart';

abstract class StatesWidgetBase<T> extends StatefulWidget {

  const StatesWidgetBase({
    super.key,
    this.hotReloadKey,
    this.states,
  });

  final int? hotReloadKey;
  final States<T>? states;
  
  @override
  StatesWidgetBaseState<StatesWidgetBase<T>, T> createState();
}

abstract class StatesWidgetBaseState<W extends StatesWidgetBase<T>, T> 
  extends State<W> implements Observer<T> {

  @protected
  Disposable? observation;
  @protected
  States<T>? observedStates;

  @protected
  States<T> resolveStates() => widget.states ?? context.scope.getStates<T>();
  
  @override
  void initState() {
    super.initState();
    final newStates = resolveStates();
    startObserve(newStates);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) { // enable hot reload
      final newStates = resolveStates();
      bool statesChanged() => !deepObservableEquality
        .equals(observedStates!.observable, newStates.observable);
      final hotReloadKeyChanged = oldWidget.hotReloadKey != widget.hotReloadKey;
      if (hotReloadKeyChanged || statesChanged()) {
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
    observedStates = newStates;
    observation = newStates.observe(onData);
  }

  @protected
  void stopObserve() {
    observation?.dispose();
    observation = null;
    observedStates = null;
  }
}

typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T state);

class StatesBuilder<T> extends StatesWidgetBase<T> {

  const StatesBuilder({
    super.key,
    super.hotReloadKey,
    super.states,
    required this.builder,
  });

  final StateWidgetBuilder<T> builder;

  @override
  createState() => _StatesBuilderState<T>();
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
    assert(_currentState is T, 'Current state: $_currentState, should be instance of $T at build stage.');
    return widget.builder(context, _currentState as T);
  }
}

typedef FlutterOnData<T> = void Function(BuildContext context, T data);

class StatesListener<T> extends StatesWidgetBase<T> {

  const StatesListener({
    super.key,
    super.hotReloadKey,
    super.states,
    this.skipInitialState = true,
    required this.onData,
    required this.child,
  });

  final bool skipInitialState;
  final FlutterOnData<T> onData;
  final Widget child;

  @override
  createState() => _StatesListenerState<T>();
}

class _StatesListenerState<T> extends StatesWidgetBaseState<StatesListener<T>, T> {

  // Yeah, we'd better find a way to remove this override method, since 
  // `newStates.skipFirst()` logic may not belongs to `startObserve` method
  @override
  void startObserve(States<T> newStates) {
    observedStates = newStates;
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