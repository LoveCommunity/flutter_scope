
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

typedef FlutterScopeEqual = FutureOr<Scope> Function(BuildContext context);
typedef AsyncScopeWidgetBuilder = Widget Function(BuildContext context, Async<Scope> asyncScope);

class FlutterScope extends StatefulWidget {

  @experimental
  FlutterScope.scopeEqual({
    Key? key,
    required this.scopeEqual,
    this.dispose = true,
    required this.builder,
  }): super(
    key: key,
  );

  final FlutterScopeEqual scopeEqual;
  final bool dispose;
  final AsyncScopeWidgetBuilder builder;

  static Scope? maybeOf(BuildContext context) {
    final inherited = context.getElementForInheritedWidgetOfExactType<_InheritedScope>()?.widget as _InheritedScope?;
    return inherited?.scope;
  }

  @override
  FlutterScopeState createState() => FlutterScopeState();
}

class FlutterScopeState extends State<FlutterScope> {

  late Async<Scope> _asyncScope;

  @override
  void initState() {
    super.initState();
    final scope = widget.scopeEqual(context);
    if (scope is Scope) {
      _asyncScope = Async<Scope>.loaded(data: scope);
    } else {
      _asyncScope = const Async<Scope>.loading();
      scope
        .then(_onScopeLoaded)
        .catchError(_onError);
    }
  }

  void _onScopeLoaded(Scope scope) {
    if (!mounted) {
      _disposeScopeIfNeeded(scope);
      return;
    }
    setState(() {
      _asyncScope = Async<Scope>.loaded(data: scope);
    });
  }

  void _onError(Object error, StackTrace stackTrace) {
    if (!mounted) return;
    setState(() {
      _asyncScope = Async<Scope>.error(error: error, stackTrace: stackTrace); 
    });
  }

  void _disposeScopeIfNeeded(Scope? scope) {
    if (widget.dispose) {
      scope?.dispose();
    }
  }

  @override
  void dispose() {
    _disposeScopeIfNeeded(_asyncScope.data);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, _asyncScope);
    final scope = _asyncScope.data;
    if (scope != null) {
      return _InheritedScope(
        scope: scope,
        child: child,
      );
    }
    return child;
  }
}


class _InheritedScope extends InheritedWidget {

  _InheritedScope({
    Key? key,
    required this.scope,
    required Widget child,
  }): super(
    key: key,
    child: child,
  );

  final Scope scope;

  @override
  bool updateShouldNotify(_InheritedScope oldWidget) {
    return false;
  }
}

