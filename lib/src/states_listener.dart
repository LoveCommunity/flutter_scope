
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

import 'shared.dart';

typedef FlutterOnData<T> = void Function(BuildContext context, T data);

class StatesListener<T> extends StatefulWidget {

  const StatesListener.statesEqual({
    Key? key,
    required this.statesEqual,
    this.skipInitialState = true,
    required this.onData,
    required this.child,
  }): super(
    key: key,
  );

  final FlutterEqual<States<T>> statesEqual;
  final bool skipInitialState;
  final FlutterOnData<T> onData;
  final Widget child;

  @override
  _StatesListenerState<T> createState() {
    return _StatesListenerState<T>();
  }
}

class _StatesListenerState<T> extends State<StatesListener<T>> {

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
    final Observable<T> observable = widget.skipInitialState
      ? states.skipFirst()
      : states.observable;
    _observation = observable.observe(_onData);
  }

  void _stopObserve() {
    _observation.dispose();
  }

  void _onData(T data) {
    widget.onData(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
