
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:dart_scope/dart_scope.dart';

void main() {

  testWidgets('`FlutterScope.scopeEqual` assigned sync scope', (tester) async {

    final List<Async<Scope>> asyncScopes = [];

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([]),
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      )
    );

    expect(asyncScopes.length, 1);
    final asyncScope = asyncScopes.first;
    expect(asyncScope.status, AsyncStatus.loaded);
    expect(asyncScope.data, isNotNull);
    expect(asyncScope.error, null);
    expect(asyncScope.stackTrace, null);
    
  });

  testWidgets('`FlutterScope.scopeEqual` assigned sync scope, will dispose scope if `dispose` is omitted', (tester) async {

    bool disposed = false;

    final configurable = Configurable((scope) {
      scope.addDispose(() => disposed = true);
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        builder: (_, __) => Container(),
      ),
    );

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned sync scope, will dispose scope if `dispose` is true', (tester) async {
 
    bool disposed = false;

    final configurable = Configurable((scope) {
      scope.addDispose(() => disposed = true);
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        dispose: true,
        builder: (_, __) => Container(),
      ),
    );

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned sync scope, will not dispose scope if `dispose` is false', (tester) async {
 
    bool disposed = false;

    final configurable = Configurable((scope) {
      scope.addDispose(() => disposed = true);
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        dispose: false,
        builder: (_, __) => Container(),
      ),
    );

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, false);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope success', (tester) async {
 
    final List<Async<Scope>> asyncScopes = [];

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) async => Scope.root([]),
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      )
    );

    expect(asyncScopes.length, 1);
    final asyncScope1 = asyncScopes[0];
    expect(asyncScope1.status, AsyncStatus.loading);
    expect(asyncScope1.data, null);
    expect(asyncScope1.error, null);
    expect(asyncScope1.stackTrace, null);

    await tester.pump();

    expect(asyncScopes.length, 2);
    final asyncScope2 = asyncScopes[1];
    expect(asyncScope2.status, AsyncStatus.loaded);
    expect(asyncScope2.data, isNotNull);
    expect(asyncScope2.error, null);
    expect(asyncScope2.stackTrace, null);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope failed', (tester) async {

    final List<Async<Scope>> asyncScopes = [];

    final exception = Exception('custom exception');

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) async => throw exception,
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      )
    );

    expect(asyncScopes.length, 1);
    final asyncScope1 = asyncScopes[0];
    expect(asyncScope1.status, AsyncStatus.loading);
    expect(asyncScope1.data, null);
    expect(asyncScope1.error, null);
    expect(asyncScope1.stackTrace, null);

    await tester.pump();

    expect(asyncScopes.length, 2);
    final asyncScope2 = asyncScopes[1];
    expect(asyncScope2.status, AsyncStatus.error);
    expect(asyncScope2.data, null);
    expect(asyncScope2.error, exception);
    expect(asyncScope2.stackTrace, isNotNull);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will dispose scope if `dispose` is omitted', (tester) async {
 
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];

    final configurable = Configurable((scope) async {
      scope.addDispose(() => disposed = true);
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes[0].status, AsyncStatus.loading);

    await tester.pump();

    expect(asyncScopes.length, 2);
    expect(asyncScopes[1].status, AsyncStatus.loaded);

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will dispose scope if `dispose` is true', (tester) async {
  
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];

    final configurable = Configurable((scope) async {
      scope.addDispose(() => disposed = true);
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        dispose: true,
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes[0].status, AsyncStatus.loading);

    await tester.pump();

    expect(asyncScopes.length, 2);
    expect(asyncScopes[1].status, AsyncStatus.loaded);

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, true);

 });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will not dispose scope if `dispose` is false', (tester) async {
 
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];

    final configurable = Configurable((scope) async {
      scope.addDispose(() => disposed = true);
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        dispose: false,
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes[0].status, AsyncStatus.loading);

    await tester.pump();

    expect(asyncScopes.length, 2);
    expect(asyncScopes[1].status, AsyncStatus.loaded);

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, false);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will dispose scope if `dispose` is omitted, even when scope is resolved after widget been removed', (tester) async {
 
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];
    final completer = Completer<void>();

    final configurable = Configurable((scope) {
      scope.addDispose(() => disposed = true);
      return completer.future;
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes[0].status, AsyncStatus.loading);

    await tester.pumpWidget(Container());

    completer.complete(null);
    expect(disposed, false);
    await Future.microtask(() {});
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will dispose scope if `dispose` is true, even when scope is resolved after widget been removed', (tester) async {
 
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];
    final completer = Completer<void>();

    final configurable = Configurable((scope) {
      scope.addDispose(() => disposed = true);
      return completer.future;
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        dispose: true,
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes[0].status, AsyncStatus.loading);

    await tester.pumpWidget(Container());

    completer.complete(null);
    expect(disposed, false);
    await Future.microtask(() {});
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will not dispose scope if `dispose` is false, even when scope is resolved after widget been removed', (tester) async {
  
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];
    final completer = Completer<void>();

    final configurable = Configurable((scope) {
      scope.addDispose(() => disposed = true);
      return completer.future;
    });

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          configurable,
        ]),
        dispose: false,
        builder: (_, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },      
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes[0].status, AsyncStatus.loading);

    await tester.pumpWidget(Container());

    completer.complete(null);
    expect(disposed, false);
    await Future.microtask(() {});
    expect(disposed, false);

 });

  testWidgets('`FlutterScope.maybeOf` return null if there is no `FlutterScope` above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      Builder(builder: (context) {
        scope = FlutterScope.maybeOf(context);
        return Container();
      })
    );

    expect(scope, null);

  });

  testWidgets('`FlutterScope.maybeOf` return scope if there is `FlutterScope` above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          Final<String>(name: 'scopeId', equal: (_) => 'abc'),
        ]),
        builder: (_, asyncScope) {
          switch (asyncScope.status) {
            case AsyncStatus.loaded:
              return Builder(builder: (context) {
                scope = FlutterScope.maybeOf(context);
                return Container();
              });
            default:
              return Container();
          }
        },
      ),
    );

    expect(scope, isNotNull);
    final scopeId = scope?.get<String>(name: 'scopeId');
    expect(scopeId, 'abc');

  });

  testWidgets('`FlutterScope.of` throw error if there is no `FlutterScope` above', (tester) async {

    await tester.pumpWidget(
      Builder(builder: (context) {
        final _ = FlutterScope.of(context);
        return Container();
      }),
    );

    expect(
      tester.takeException(),
      isAssertionError
        .having(
          (error) => '$error',
          'description',
          contains('There is no scope accociated with context'),
        ),
    );

  });

  testWidgets('`FlutterScope.of` return scope if there is `FlutterScope` above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([]),
        builder: (_, asyncScope) {
          switch (asyncScope.status) {
            case AsyncStatus.loaded:
              return Builder(builder: (context) {
                scope = FlutterScope.of(context);
                return Container();
              });
            default:
              return Container();
          }
        },
      ),
    );

    expect(scope, isNotNull);

  });

  testWidgets('`_inheritedScope.updateShouldNotify` test coverage', (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      FutureBuilder<void>(
        future: completer.future,
        builder: (_, __) => FlutterScope.scopeEqual(
          scopeEqual: (_) => Scope.root([]),
          builder: (_, __) => Container(),
        ),
      ),
    );

    completer.complete(null);
    await Future.microtask(() {});

    await tester.pump();
  });

  testWidgets('`FlutterScope.defaultConstructor` place an inherited scope in widget tree', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        configure: [],
        child: Builder(builder: (context) {
          scope = FlutterScope.maybeOf(context);
          return Container();
        }),
      ),
    );

    expect(scope, isNotNull);

  });

  testWidgets('`FlutterScope.defaultConstructor` configure scope failed will throw assert error', (tester) async {

    final exception = Exception('custom exception');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Configurable((scope) => throw exception),
        ],
        child: Container(),
      ),
    );

    expect(
      tester.takeException(),
      isInstanceOf<AssertionError>()
        .having(
          (exception) => exception.toString(),
          'description',
          contains("`FlutterScope` default construct should not throw error when creating scope, $exception"),
        ),
    );

  });

  testWidgets('`FlutterScope.defaultConstructor` configure scope async will throw assert error', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Configurable((scope) async {}),
        ],
        child: Container(),
      ),
    );

    expect(
      tester.takeException(),
      isInstanceOf<AssertionError>()
        .having(
          (exception) => exception.toString(),
          'description',
          contains("`FlutterScope` default construct is for configuring scope synchronounsly, please check if all provided configurables are synchronous. if there should be async configurable consider using `FlutterScope.async`."),
        ),
    );

  });

  testWidgets("`FlutterScope.defaultConstructor` nested scope inherit values from implicity parent scope", (tester) async {

    Scope? parent;
    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<String>(name: 'state1', equal: (_) => 'a'),
        ],
        child: Builder(builder: (context) {
          parent = FlutterScope.maybeOf(context);
          return FlutterScope(
            configure: [
              Final<String>(name: 'state2', equal: (_) => 'b'),
            ],
            child: Builder(builder: (context) {
              scope = FlutterScope.maybeOf(context);
              return Container();
            }),
          );
        }),
      ),
    );

    expect(parent, isNotNull);
    expect(scope, isNotNull);

    final parentState1 = parent?.getOrNull<String>(name: 'state1');
    final parentState2 = parent?.getOrNull<String>(name: 'state2');
    final scopeState1 = scope?.getOrNull<String>(name: 'state1');
    final scopeState2 = scope?.getOrNull<String>(name: 'state2');

    expect(parentState1, 'a');
    expect(parentState2, null);
    expect(scopeState1, 'a');
    expect(scopeState2, 'b');

  });

  testWidgets("`FlutterScope.defaultConstructor` created scope inherit values from explicitly parent scope", (tester) async {

    final Scope parent = await Scope.root([
      Final<String>(name: 'state1', equal: (_) => 'a'),
    ]);

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        parentScope: parent,
        configure: [
          Final<String>(name: 'state2', equal: (_) => 'b'),
        ],
        child: Builder(builder: (context) {
          scope = FlutterScope.maybeOf(context);
          return Container();
        }),
      ),
    );

    expect(scope, isNotNull);

    final parentState1 = parent.getOrNull<String>(name: 'state1');
    final parentState2 = parent.getOrNull<String>(name: 'state2');
    final scopeState1 = scope?.getOrNull<String>(name: 'state1');
    final scopeState2 = scope?.getOrNull<String>(name: 'state2');

    expect(parentState1, 'a');
    expect(parentState2, null);
    expect(scopeState1, 'a');
    expect(scopeState2, 'b');

  });

  testWidgets('`FlutterScope.defaultConstructor` dispose registered resouces when `FlutterScope` is removed from widget tree', (tester) async {

    bool disposed = false;

    final configurable = Configurable((scope) {
      scope.addDispose(() {
        disposed = true;
      });
    });

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          configurable,
        ],
        child: Container(),
      )
    );

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.using` place an inherited scope in widget tree using an existing scope', (tester) async {

    final existingScope = await Scope.root([]);

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.using(
        existingScope: existingScope,
        child: Builder(builder: (context) {
          scope = FlutterScope.maybeOf(context);
          return Container();
        }),
      ),
    );

    final isScopeIdentical = identical(existingScope, scope); 
    expect(isScopeIdentical, true);

  });

  testWidgets("`FlutterScope.using` won't dispose registered resouces when `FlutterScope` is removed from widget tree", (tester) async {

    bool disposed = false;

    final configurable = Configurable((scope) {
      scope.addDispose(() {
        disposed = true;
      });
    });

    final existingScope = await Scope.root([
      configurable,
    ]);

    await tester.pumpWidget(
      FlutterScope.using(
        existingScope: existingScope,
        child: Container(),
      ),
    );

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, false);

  });

  testWidgets('`FlutterScope.async` build with `asyncScope` when resolve scope success', (tester) async {

    final List<Async<Scope>> asyncScopes = [];

    final completer = Completer<void>();

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          Configurable((scope) => completer.future),
        ],
        builder: (context, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes.last.status, AsyncStatus.loading);

    completer.complete(null);
    await Future.microtask(() {});
    await tester.pump();

    expect(asyncScopes.length, 2);
    expect(asyncScopes.last.status, AsyncStatus.loaded);
    expect(asyncScopes.last.data, isNotNull);
    
  });

  testWidgets('`FlutterScope.async` build with `asyncScope` when resolve scope failed', (tester) async {

    final List<Async<Scope>> asyncScopes = [];

    final completer = Completer<void>();

    final exception = Exception('custom exception');

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          Configurable((scope) => completer.future),
        ],
        builder: (context, asyncScope) {
          asyncScopes.add(asyncScope);
          return Container();
        },
      ),
    );

    expect(asyncScopes.length, 1);
    expect(asyncScopes.last.status, AsyncStatus.loading);

    completer.completeError(exception);
    await Future.microtask(() {});
    await tester.pump();

    expect(asyncScopes.length, 2);
    expect(asyncScopes.last.status, AsyncStatus.error);
    expect(asyncScopes.last.error, exception);
    
  });

  testWidgets('`FlutterScope.async` place an inherited scope in widget tree after scope resolved success', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          Configurable((scope) async {}),
        ],
        builder: (_, __) {
          return Builder(builder: (context) {
            scope = FlutterScope.maybeOf(context);
            return Container();
          });
        }
      ),
    );

    expect(scope, null);
    await tester.pump();
    expect(scope, isNotNull);

  });

  testWidgets('`FlutterScope.async` nested scope inherit values from implicity parent scope', (tester) async {

    Scope? parent;
    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<String>(name: 'state1', equal: (_) => 'a'),
        ],
        child: Builder(builder: (context) {
          parent = FlutterScope.maybeOf(context);
          return FlutterScope.async(
            configure: [
              Final<String>(name: 'state2', equal: (_) => 'b'),
              Configurable((scope) async {}),
            ],
            builder: (_, __) {
              return Builder(builder: (context) {
                scope = FlutterScope.maybeOf(context);
                return Container();
              });
            },
          );
        }),
      )
    );
    
    await tester.pump();

    expect(parent, isNotNull);
    expect(scope, isNotNull);

    final parentState1 = parent?.getOrNull<String>(name: 'state1');
    final parentState2 = parent?.getOrNull<String>(name: 'state2');
    final scopeState1 = scope?.getOrNull<String>(name: 'state1');
    final scopeState2 = scope?.getOrNull<String>(name: 'state2');

    expect(parentState1, 'a');
    expect(parentState2, null);
    expect(scopeState1, 'a');
    expect(scopeState2, 'b');

  });

  testWidgets('`FlutterScope.async` created scope inherit values from explicitly parent scope', (tester) async {
    
    Scope? scope;

    final parent = await Scope.root([
      Final<String>(name: 'state1', equal: (_) => 'a'),
    ]);
    
    await tester.pumpWidget(
      FlutterScope.async(
        parentScope: parent, configure: [
          Final<String>(name: 'state2', equal: (_) => 'b'),
          Configurable((scope) async {}),
        ],
        builder: (_, __) {
          return Builder(builder: (context) {
            scope = FlutterScope.maybeOf(context);
            return Container();
          });
        },
      ),
    );

    await tester.pump();

    expect(scope, isNotNull);

    final parentState1 = parent.getOrNull<String>(name: 'state1');
    final parentState2 = parent.getOrNull<String>(name: 'state2');
    final scopeState1 = scope?.getOrNull<String>(name: 'state1');
    final scopeState2 = scope?.getOrNull<String>(name: 'state2');

    expect(parentState1, 'a');
    expect(parentState2, null);
    expect(scopeState1, 'a');
    expect(scopeState2, 'b');

  });

  testWidgets('`FlutterScope.async` dispose registered resouces when `FlutterScope` is removed from widget tree', (tester) async {
    
    bool disposed = false;

    final configurable = Configurable((scope) async {
      scope.addDispose(() {
        disposed = true;
      });
    });

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable,
        ],
        builder: (_, __) => Container(),
      ),
    );

    await tester.pump();

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.async` defer dispose registered resouces when `FlutterScope` is removed from widget tree and scope is not yet resolved', (tester) async {
    
    bool disposed = false;
    final completer = Completer<void>();

    final configurable = Configurable((scope) {
      scope.addDispose(() {
        disposed = true;
      });
      return completer.future;
    });

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable,
        ],
        builder: (_, __) => Container(),
      ),
    );

    await tester.pumpWidget(Container());

    completer.complete(null);
    expect(disposed, false);
    await Future.microtask(() {});
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.async` dispose registered resouces when resolve scope failed', (tester) async {

    bool disposed = false;
    final completer = Completer<void>();

    final configurable = Configurable((scope) {
      scope.addDispose(() {
        disposed = true;
      });
      return completer.future;
    });
    
    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable,
        ],
        builder: (_, __) => Container(),
      ),
    );

    completer.completeError(Exception());
    expect(disposed, false);
    await Future.microtask(() {});
    expect(disposed, true);

  });

  testWidgets('`context.scopeOrNull` return null if there is no `FlutterScope` above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      Builder(builder: (context) {
        scope = context.scopeOrNull;
        return Container();
      })
    );

    expect(scope, null);

  });

  testWidgets('`context.scopeOrNull` return scope if there is `FlutterScope` above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.scopeEqual(
        scopeEqual: (_) => Scope.root([
          Final<String>(name: 'scopeId', equal: (_) => 'abc'),
        ]),
        builder: (_, asyncScope) {
          switch (asyncScope.status) {
            case AsyncStatus.loaded:
              return Builder(builder: (context) {
                scope = context.scopeOrNull;
                return Container();
              });
            default:
              return Container();
          }
        },
      ),
    );

    expect(scope, isNotNull);
    final scopeId = scope?.get<String>(name: 'scopeId');
    expect(scopeId, 'abc');

  });
}

