
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

import 'shared.dart';

typedef StateWidgetBuilder<T> = Widget Function(BuildContext context, T state);

class StatesBuilder<T> extends StatefulWidget {

  StatesBuilder.statesEqual({
    Key? key,
    required this.statesEqual,
    required this.builder,
  }): super(
    key: key,
  );

  final FlutterEqual<States<T>> statesEqual;
  final StateWidgetBuilder builder;

  @override
  _StatesBuilderState<T> createState() {
    return _StatesBuilderState<T>();
  }
}

class _StatesBuilderState<T> extends State<StatesBuilder<T>> {

  late T _currentState;
  late final Disposable _observation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _startObserve();
    _initialized = true;
  }

  @override
  void dispose() {
    _stopObserve();
    super.dispose();
  }

  void _startObserve() {
    final States<T> states = widget.statesEqual(context);
    _observation = states.observe(_setCurrentState);
  }

  void _stopObserve() {
    _observation.dispose();
  }

  void _setCurrentState(T state) {
    if (!_initialized) {
      _currentState = state;
    } else {
      setState(() {
        _currentState = state;
      });
    }
  }

  Widget build(BuildContext context) {
    return widget.builder(context, _currentState);
  }
}
