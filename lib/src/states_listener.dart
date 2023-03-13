
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

import 'shared.dart';

@experimental
typedef FlutterOnData<T> = void Function(BuildContext context, T data);

@experimental
class StatesListener<T> extends StatefulWidget {

  StatesListener({
    Key? key,
    Object? name,
    bool skipInitialState = true,
    required FlutterOnData<T> onData,
    required Widget child,
  }): this.statesEqual(
    key: key,
    statesEqual: contextGetStates<T>(
      name: name,
    ),
    skipInitialState: skipInitialState,
    onData: onData,
    child: child,
  );

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
  createState() => _StatesListenerState<T>();
}

@experimental
class StatesListenerConvert<T, R> extends StatesListener<R> {

  StatesListenerConvert({
    Key? key,
    Object? name,
    required R Function(T state) convert,
    Equals<R>? equals,
    bool skipInitialState = true,
    required FlutterOnData<R> onData,
    required Widget child,
  }): super.statesEqual(
    key: key,
    statesEqual: contextConvertStates<T, R>(
      name: name,
      convert: convert,
      equals: equals,
    ),
    skipInitialState: skipInitialState,
    onData: onData,
    child: child,
  );
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
