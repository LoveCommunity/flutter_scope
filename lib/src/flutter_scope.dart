
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

typedef FlutterScopeEqual = FutureOr<Scope> Function(BuildContext context);
typedef AsyncScopeWidgetBuilder = Widget Function(BuildContext context, Async<Scope> asyncScope);

class FlutterScope extends StatefulWidget {

  FlutterScope({
    Key? key,
    required List<Configurable> configure,
    required Widget child,
  }): this.scopeEqual(
    key: key,
    scopeEqual: _defaultConstructScopeEqual(configure),
    dispose: true,
    builder: _defaultConsctructBuilder(child),
  );

  FlutterScope.using({
    Key? key,
    required Scope existingScope,
    required Widget child,
  }): this.scopeEqual(
    key: key,
    scopeEqual: (_) => existingScope,
    dispose: false,
    builder: (_, __) => child,
  );

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

FlutterScopeEqual _defaultConstructScopeEqual(List<Configurable> configure) {
  return (context) {
    final scope = FlutterScope.maybeOf(context);
    return scope?.push(configure) ?? Scope.root(configure);
  };
}

AsyncScopeWidgetBuilder _defaultConsctructBuilder(Widget child) {
  return (_, asyncScope) {
    assert(
      asyncScope.status != AsyncStatus.error, 
      '`FlutterScope` default construct should not throw error when creating scope, ${asyncScope.error}, ${asyncScope.stackTrace}', 
    );
    assert(
      asyncScope.status != AsyncStatus.loading,
      "`FlutterScope` default construct is for configuring scope synchronounsly, please check if all provided configurables are synchronous. if there should be async configurable consider using `FlutterScope.async`."
    );
    return child;
  };
}

class FlutterScopeState extends State<FlutterScope> {

  late Async<Scope> _asyncScope;

  @override
  void initState() {
    super.initState();
    _initScope();
  }

  void _initScope() {
    try {
      final scope = widget.scopeEqual(context);
      if (scope is Scope) {
        _asyncScope = Async<Scope>.loaded(data: scope);
      } else {
        _asyncScope = const Async<Scope>.loading();
        scope
          .then(_onScopeLoaded)
          .catchError(_onError);
      }
    } catch (error, stackTrace) {
      _asyncScope = Async<Scope>.error(error: error, stackTrace: stackTrace);
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

