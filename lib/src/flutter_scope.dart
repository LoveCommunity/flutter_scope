
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

import 'configurable_equality.dart';

/// A `Builder` build a widget with an async scope.
typedef AsyncScopeWidgetBuilder = Widget Function(BuildContext context, Async<Scope> asyncScope);

/// FlutterScope is the range that something within it can be accessed.
class FlutterScope extends StatefulWidget {

  /// Use `FlutterScope(...)` to create a scope with configurations.
  /// 
  /// ```dart
  /// FlutterScope(
  ///   configure: [
  ///     FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
  ///       name: 'todosNotifier',
  ///       equal: (_) => TodosNotifier(),
  ///     ),
  ///     FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
  ///       name: 'todoFilterNotifier',
  ///       equal: (_) => TodoFilterNotifier(),
  ///     ),
  ///   ],
  ///   child: Builder(
  ///     builder: (context) {
  ///       final myTodosNotifier = context.scope.get<TodosNotifier>(name: 'todosNotifier');
  ///       final myTodoFilterNotifier = context.scope.get<TodoFilterNotifier>(name: 'todoFilterNotifier');
  ///       return ...;
  ///     }
  ///   ),
  /// );
  /// ```
  /// 
  /// Above example simulates:
  /// 
  /// ```dart
  /// void flutterScope() { // `{` is the start of scope
  /// 
  ///   // create and exposed instances in current scope
  ///   final TodosNotifier todosNotifier = TodosNotifier();
  ///   final TodoFilterNotifier todoFilterNotifier = TodoFilterNotifier();
  /// 
  ///   // resolve instances in current scope
  ///   final myTodosNotifier = todosNotifier;
  ///   final myTodoFilterNotifier = todoFilterNotifier;
  /// 
  /// }                     // `}` is the end of scope
  /// ```
  /// 
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

  /// Use `FlutterScope.async(...)` to create a scope with async configurations.
  /// 
  /// If there is async setup like resolving `SharedPreference`. We can follow this: 
  ///
  /// ```dart
  /// Future<Map<String, Todo>> resolveInitialTodosAsync() {
  ///   await Future<void>.delayed(Duration(seconds: 1));
  ///   return { ... };
  /// }
  /// 
  /// ...
  /// 
  /// FlutterScope.async( // use `async` constructor
  ///   configure: [
  ///     // using `AsyncFinal` to handle async setup
  ///     AsyncFinal<Map<String, Todo>>(
  ///       equal: (_) async {
  ///         return await resolveInitialTodosAsync();
  ///       },
  ///     ),
  ///     FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
  ///       equal: (scope) => TodosNotifier(
  ///         scope.get<Map<String, Todo>>(),
  ///       ),
  ///     ),
  ///   ],
  ///   builder: (context, asyncScope) {
  ///     switch (asyncScope.status) {
  ///       case AsyncStatus.loading:
  ///         return ...; // loading widget
  ///       case AsyncStatus.error:
  ///         return ...; // error widget
  ///       case AsyncStatus.loaded:
  ///         final scope = asyncScope.requireData;
  ///         final myTodosNotifier = scope.get<TodosNotifier>();
  ///         return ...; // success widget
  ///     },
  ///   },
  /// );
  /// ```
  /// 
  /// Which simulates:
  /// 
  /// ```dart
  /// void flutterScope() async {
  ///   final Map<String, Todo> initialTodos = await resolveInitialTodosAsync();
  ///   final TodosNotifier todosNotifier = TodosNotifier(initialTodos);
  /// 
  ///   final myTodosNotifier = todosNotifier;
  /// }
  /// ```
  ///
  const FlutterScope.async({
    super.key,
    this.hotReloadKey,
    this.parentScope,
    required this.configure,
    required this.builder,
  });

  /// Change this key will trigger hot reload with new configurations.
  /// 
  /// When `hotReloadKey` is different from old one, old scope will be
  /// replaced with new scope created using new configurations.
  /// 
  /// It only has effect in debug mode, since it is designed for
  /// manually triggering hot reload.
  /// 
  /// See implementation in method `_flutterScopeState.didUpdateWidget`.
  /// 
  final int? hotReloadKey;
  /// The parent scope
  final Scope? parentScope;
  /// The configurations
  final List<Configurable> configure;
  /// Built widget with an async scope
  final AsyncScopeWidgetBuilder builder;

  /// Resolve `Scope` which is inherited from context.
  /// Return null if there is no scope inherited.
  static Scope? maybeOf(BuildContext context) {
    final inherited = context.getElementForInheritedWidgetOfExactType<InheritedScope>()?.widget as InheritedScope?;
    return inherited?.scope;
  }

  /// Resolve `Scope` which is inherited from context.
  /// Throws `error` if there is no scope inherited.
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


/// Use `InheritedScope` for making an exist scope available to subtree. 
/// 
/// This is useful when current route share scope with new route:
/// 
/// ```dart
/// FlutterScope(
///   configure: [
///     FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
///       equal: (_) => TodosNotifier(),
///     ),
///     FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
///       equal: (_) => TodoFilterNotifier(),
///     ),
///   ],
///   child: Builder(
///     builder: (context) {
///       return Scaffold(
///         ...
///         floatActionButton: FloatActionButton(
///           onPressed: () => _showAddTodoDialog(context),
///           child: ...,
///         ),
///       ),
///     },
///   ),
/// );
/// 
/// ...
/// 
/// void _showAddTodoDialog(BuildContext context) {
///   showDialog( // show dialog will push a new route
///     context: context,
///     builder: (_) {
///       return InheritedScope(  // use `InheritedScope` for
///         scope: context.scope, // making exist scope available to subtree
///         child: AlertDialog(
///           ...,
///           content: Builder(
///             builder: (context) {
///               // resolve instance in new route
///               final myTodosNotifier = context.scope.get<TodosNotifier>();
///               return ...;
///             },
///           ),
///         ),
///       );
///     },
///   );
/// }
/// ```
/// 
/// Above example shown:
///  - press `FloatActionButton` will push a new route
///  - passing scope from current route to new route using `InheritedScope`
///  - resolve `TodosNotifier` in new route
/// 
class InheritedScope extends InheritedWidget {

  /// Create a `InheritedScope` with an exist scope.
  const InheritedScope({
    super.key,
    required this.scope,
    required super.child,
  });

  /// The inherited `scope` for subtree
  final Scope scope;

  @override
  bool updateShouldNotify(InheritedScope oldWidget) {
    return false;
  }
}

/// `BuildContextScopeX` is an extension to `BuildContext`
/// which add convenience methods to access `Scope`.
extension BuildContextScopeX on BuildContext {

  /// Resolve `Scope` which is inherited from context.
  /// Return null if there is no scope inherited.
  Scope? get scopeOrNull {
    return FlutterScope.maybeOf(this);
  }

  /// Resolve `Scope` which is inherited from context.
  /// Throws `error` if there is no scope inherited.
  Scope get scope {
    return FlutterScope.of(this);
  }
}

