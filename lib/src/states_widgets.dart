
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