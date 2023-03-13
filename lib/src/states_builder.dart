
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

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
    super.key,
    required this.statesEqual,
    required this.builder,
  });

  final FlutterEqual<States<T>> statesEqual;
  final StateWidgetBuilder<T> builder;

  @override
  createState() => _StatesBuilderState<T>();
}

class StatesBuilderConvert<T, R> extends StatesBuilder<R> {

  StatesBuilderConvert({
    super.key,
    Object? name,
    required R Function(T state) convert,
    Equals<R>? equals,
    required super.builder,
  }): super.statesEqual(
    statesEqual: contextConvertStates<T, R>(
      name: name,
      convert: convert,
      equals: equals,
    ),
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
