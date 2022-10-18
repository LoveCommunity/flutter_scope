
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';
import 'package:typedef_equals/typedef_equals.dart';

import 'shared.dart';

typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T state);

class StatesBuilder<T> extends StatefulWidget {

  StatesBuilder({
    Key? key,
    Object? name,
    required StateWidgetBuilder<T> builder,
  }): this.statesEqual(
    key: key,
    statesEqual: contextGetStates<T>(
      name: name
    ),
    builder: builder,
  );

  const StatesBuilder.statesEqual({
    Key? key,
    required this.statesEqual,
    required this.builder,
  }): super(
    key: key,
  );

  final FlutterEqual<States<T>> statesEqual;
  final StateWidgetBuilder<T> builder;

  @override
  _StatesBuilderState<T> createState() {
    return _StatesBuilderState<T>();
  }
}

class StatesBuilderSelect<T, R> extends StatesBuilder<R> {

  StatesBuilderSelect({
    Key? key,
    Object? name,
    required R Function(T state) select,
    Equals<R>? equals,
    required StateWidgetBuilder<R> builder,
  }): super.statesEqual(
    key: key,
    statesEqual: contextSelectStates<T, R>(
      name: name,
      select: select,
      equals: equals,
    ),
    builder: builder,
  );
}

class _StatesBuilderState<T> extends State<StatesBuilder<T>> {

  late T _currentState;
  late final Disposable _observation;

  @override
  void initState() {
    super.initState();
    _startObserve();
  }

  @override
  void dispose() {
    _stopObserve();
    super.dispose();
  }

  void _startObserve() {
    final States<T> states = widget.statesEqual(context);
    _observation = states.observe(_onData);
  }

  void _stopObserve() {
    _observation.dispose();
  }

  void _onData(T state) {
    setState(() {
      _currentState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentState);
  }
}
