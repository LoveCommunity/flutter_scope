
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'flutter_scope.dart';
import 'observable_equality.dart';

/// `StatesWidgetBase` transform an input `States` to an output widget.
abstract class StatesWidgetBase<T> extends StatefulWidget {

  /// Create a `StatesWidgetBase` with input `States`
  const StatesWidgetBase({
    super.key,
    this.hotReloadKey,
    this.states,
  });

  /// Change this key will trigger hot reload with new input states. 
  /// 
  /// When `hotReloadKey` is different from old one, old observation
  /// will be replaced with new observation using new states.
  /// 
  /// It only has effect in debug mode, since it is designed for 
  /// manually triggering hot reload. 
  /// 
  /// See implementation in method `statesWidgetBaseState.didUpdateWidget`.
  /// 
  final int? hotReloadKey;
  /// The input states.
  final States<T>? states;
  
  @override
  StatesWidgetBaseState<StatesWidgetBase<T>, T> createState();
}

/// The logic and internal state for a [StatesWidgetBaseState].
abstract class StatesWidgetBaseState<W extends StatesWidgetBase<T>, T> 
  extends State<W> implements Observer<T> {
  
  /// Currently active observation.
  @protected
  Disposable? observation;
  /// Currently observed states.
  @protected
  States<T>? observedStates;

  /// Resolve current states from widget or context.
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

  /// Start observe new states.
  @protected
  void startObserve(States<T> newStates) {
    observedStates = newStates;
    observation = newStates.observe(onData);
  }

  /// Stop observe current states.
  @protected
  void stopObserve() {
    observation?.dispose();
    observation = null;
    observedStates = null;
  }
}

/// A `Builder` build a widget with a state.
typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T state);

/// `StatesBuilder` transform a sequence of state to widget.
class StatesBuilder<T> extends StatesWidgetBase<T> {

  /// Use `StatesBuilder(...)` to map a sequence of state to widget, as `UI = f(state).` 
  /// 
  /// ```dart
  /// FlutterScope(
  ///   configure: [
  ///     FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
  ///       equal: (_) => TodoFilterNotifier(),
  ///     ),
  ///   ],
  ///   child: StatesBuilder<TodoFilter>(
  ///     builder: (context, todoFilter) {
  ///       return ...; // map state to widget
  ///     },
  ///   ),
  /// );
  /// ```
  /// 
  /// Which simulates:
  /// 
  /// ```dart
  /// void flutterScope() async {
  ///   final TodoFilterNotifier todosFilterNotifier = TodoFilterNotifier();
  ///   final States<TodoFilter> todoFilterStates = todosFilterNotifierAsStates(todosFilterNotifier);
  /// 
  ///   late TodoFilter state;
  ///   final observation = todoFilterStates.observe((todoFilter) {
  ///     print('simulate flutter set state');
  ///     state = todoFilter;
  ///     print('simulate map state to widget');
  ///   }); 
  /// 
  ///   ...
  /// }
  /// 
  /// ...
  /// ```
  ///  
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

/// `FlutterOnData` is a function describe how to handle data with a context.
typedef FlutterOnData<T> = void Function(BuildContext context, T data);

/// `StatesListener` add a listener in flutter layer.
class StatesListener<T> extends StatesWidgetBase<T> {

  /// Use `StatesListener(...)` to add a listener in flutter layer.
  /// 
  /// ```dart
  /// FlutterScope(
  ///   configure: [
  ///     FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
  ///       equal: (_) => TodoFilterNotifier(),
  ///     ),
  ///   ],
  ///   child: StatesListener<TodoFilter>(
  ///     onData: (context, todoFilter) {
  ///       ScaffoldMessenger.of(context)
  ///         .showSnackbar(SnackBar(
  ///           content: Text('todo filter changed to $todoFilter'),
  ///         ));
  ///     },
  ///     child: ...,
  ///   ),
  /// );
  /// ```
  /// 
  /// Which simulates:
  /// 
  /// ```dart
  /// void flutterScope() async {
  ///   final TodoFilterNotifier todosFilterNotifier = TodoFilterNotifier();
  ///   final States<TodoFilter> todoFilterStates = todosFilterNotifierAsStates(todosFilterNotifier);
  /// 
  ///   final observation = todoFilterStates.observe((todoFilter) {
  ///     print('todo filter changed to $todoFilter');
  ///   }); 
  /// 
  ///   ...
  /// }
  /// 
  /// ...
  /// ```
  /// 
  const StatesListener({
    super.key,
    super.hotReloadKey,
    super.states,
    this.skipInitialState = true,
    required this.onData,
    required this.child,
  });

  /// Controls whether to skip initial state
  final bool skipInitialState;
  /// Handler handles new state
  final FlutterOnData<T> onData;
  /// The child widget
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