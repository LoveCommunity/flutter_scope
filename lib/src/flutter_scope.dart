
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter_scope/src/configurable_equality.dart';

typedef AsyncScopeWidgetBuilder = Widget Function(BuildContext context, Async<Scope> asyncScope);

class FlutterScope extends StatefulWidget {

  FlutterScope({
    Key? key,
    int? hotReloadKey,
    Scope? parentScope,
    required List<Configurable> configure,
    required Widget child,
  }): this.async(
    key: key,
    hotReloadKey: hotReloadKey,
    parentScope: parentScope,
    configure: configure,
    builder: _syncScopeWidgetBuilder(child),
  );

  const FlutterScope.async({
    super.key,
    this.hotReloadKey,
    this.parentScope,
    required this.configure,
    required this.builder,
  });

  final int? hotReloadKey;
  final Scope? parentScope;
  final List<Configurable> configure;
  final AsyncScopeWidgetBuilder builder;

  static Scope? maybeOf(BuildContext context) {
    final inherited = context.getElementForInheritedWidgetOfExactType<InheritedScope>()?.widget as InheritedScope?;
    return inherited?.scope;
  }

  static Scope of(BuildContext context) {
    final scope = FlutterScope.maybeOf(context);
    assert(scope != null, 'There is no scope associated with context: $context');
    return scope!;
  }

  @override
  createState() => _FlutterScopeState();
}

AsyncScopeWidgetBuilder _syncScopeWidgetBuilder(Widget child) {
  return (_, asyncScope) {
    assert(
      asyncScope.status != AsyncStatus.error, 
      '`FlutterScope` default construct should not throw error when creating scope, ${asyncScope.error}, ${asyncScope.stackTrace}', 
    );
    assert(
      asyncScope.status != AsyncStatus.loading,
      "`FlutterScope` default construct is for configuring scope synchronously, please check if all provided configurables are synchronous. if there should be async configurable consider using `FlutterScope.async`."
    );
    return child;
  };
}

class _FlutterScopeState extends State<FlutterScope> {

  Object? _currentScopeTicket;
  Scope? _currentParentScope;
  List<Configurable>? _currentConfigure;
  Async<Scope>? _currentAsyncScope;

  Scope? _resolveParentScope() => widget.parentScope ?? FlutterScope.maybeOf(context);
  bool _parentScopeChanged() => !identical(_currentParentScope, _resolveParentScope());
  bool _configureChanged() => !configurableListEquality.equals(_currentConfigure, widget.configure);

  @override
  void initState() {
    super.initState();
    _createScope();
  }

  @override
  void didUpdateWidget(covariant FlutterScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) { // enabling hot reload
      final hotReloadKeyChanged = oldWidget.hotReloadKey != widget.hotReloadKey;
      if (hotReloadKeyChanged || _parentScopeChanged() || _configureChanged()) {
        _disposeScope();
        _createScope();
      }
    }
  }

  @override
  void dispose() {
    _disposeScope();
    super.dispose();
  }

  void _createScope() {
    final scopeTicket = Object();
    _currentScopeTicket = scopeTicket;
    final parentScope = _resolveParentScope();
    _currentParentScope = parentScope;
    _currentConfigure = widget.configure;
    try {
      final futureOrScope = parentScope?.push(widget.configure)
        ?? Scope.root(widget.configure);
      if (futureOrScope is Scope) {
        _currentAsyncScope = Async<Scope>.loaded(data: futureOrScope);
      } else {
        _currentAsyncScope = const Async<Scope>.loading();
        futureOrScope
          .then((scope) => _onScopeLoaded(scope, scopeTicket))
          .catchError((Object error, StackTrace stackTrace) => _onScopeLoadError(error, stackTrace, scopeTicket));
      }
    } catch (error, stackTrace) {
      _currentAsyncScope = Async<Scope>.error(error: error, stackTrace: stackTrace);
    }
  }
  
  void _disposeScope() {
    _currentAsyncScope?.data?.dispose();
    _currentAsyncScope = null;
    _currentConfigure = null;
    _currentParentScope = null;
    _currentScopeTicket = null;
  }

  void _onScopeLoaded(Scope scope, Object scopeTicket) {
    if (_currentScopeTicket == scopeTicket) {
      setState(() {
        _currentAsyncScope = Async<Scope>.loaded(data: scope);
      });
    } else {
      scope.dispose();
    }
  }

  void _onScopeLoadError(Object error, StackTrace stackTrace, Object scopeTicket) {
    if (_currentScopeTicket == scopeTicket) {
      setState(() {
        _currentAsyncScope = Async<Scope>.error(error: error, stackTrace: stackTrace);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _currentAsyncScope != null,
      '`_currentAsyncScope` should not be null at build stage.'
    );
    final scope = _currentAsyncScope?.data;
    final child = widget.builder(context, _currentAsyncScope!);
    if (scope != null) {
      return InheritedScope(
        key: kDebugMode ? ObjectKey(scope) : null,
        scope: scope,
        child: child,
      );
    }
    return child;
  }
}


class InheritedScope extends InheritedWidget {

  const InheritedScope({
    super.key,
    required this.scope,
    required super.child,
  });

  final Scope scope;

  @override
  bool updateShouldNotify(InheritedScope oldWidget) {
    return false;
  }
}

extension BuildContextScopeX on BuildContext {

  Scope? get scopeOrNull {
    return FlutterScope.maybeOf(this);
  }

  Scope get scope {
    return FlutterScope.of(this);
  }
}

