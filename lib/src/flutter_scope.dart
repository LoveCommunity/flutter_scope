
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';
import 'package:flutter_scope/src/configurable_equality.dart';

typedef FlutterScopeEqual = FutureOr<Scope> Function(BuildContext context);
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
    builder: _defaultConstructBuilder(child),
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
  createState() => FlutterScopeState();
}

class FlutterScopeState extends State<FlutterScope> {

  Async<Scope>? _asyncScope;
  Object? _currentScopeTicket;
  Scope? _currentParentScope;
  List<Configurable>? _currentConfigure;

  Scope? get _parentScope => widget.parentScope ?? FlutterScope.maybeOf(context);

  @override
  void initState() {
    super.initState();
    _createScope(_parentScope, widget.configure);
  }

  @override
  void didUpdateWidget(covariant FlutterScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      final parentScope = _parentScope;
      final hotReloadKeyChanged = oldWidget.hotReloadKey != widget.hotReloadKey;
      final parentScopeChanged = _currentParentScope != parentScope;
      final configureChanged = !configurableListEquality.equals(_currentConfigure, widget.configure);
      if (hotReloadKeyChanged || parentScopeChanged || configureChanged) {
        _disposeScope();
        _createScope(parentScope, widget.configure);
      }
    }
  }

  @override
  void dispose() {
    _disposeScope();
    super.dispose();
  }

  void _createScope(Scope? parentScope, List<Configurable> configure) {
    final scopeTicket = Object();
    _currentScopeTicket = scopeTicket;
    _currentParentScope = parentScope;
    _currentConfigure = configure;
    try {
      final futureOrScope = parentScope == null
        ? Scope.root(configure)
        : parentScope.push(configure);
      if (futureOrScope is Scope) {
        _onScopeLoaded(futureOrScope, scopeTicket);
      } else {
        _asyncScope = const Async<Scope>.loading();
        futureOrScope
          .then((scope) => _onScopeLoaded(scope, scopeTicket))
          .catchError((Object error, StackTrace stackTrace) => _onError(error, stackTrace, scopeTicket));   
      }
    } catch (error, stackTrace) {
      _onError(error, stackTrace, scopeTicket);
    }
  }

  void _disposeScope() {
    _asyncScope?.data?.dispose();
    _asyncScope = null;
    _currentConfigure = null;
    _currentParentScope = null;
    _currentScopeTicket = null;
  }

  void _onScopeLoaded(Scope scope, Object scopeTicket) {
    if (_currentScopeTicket == scopeTicket) {
      setState(() {
        _asyncScope = Async<Scope>.loaded(data: scope);
      });
    } else {
      scope.dispose();
    }
  }

  void _onError(Object error, StackTrace stackTrace, Object scopeTicket) {
    if (_currentScopeTicket == scopeTicket) {
      setState(() {
        _asyncScope = Async<Scope>.error(error: error, stackTrace: stackTrace);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    assert(_asyncScope != null, '`_asyncScope` should not be null at build stage.');
    final child = widget.builder(context, _asyncScope!);
    final scope = _asyncScope!.data;
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

AsyncScopeWidgetBuilder _defaultConstructBuilder(Widget child) {
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

