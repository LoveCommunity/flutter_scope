
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scope/flutter_scope.dart';

void main() {

  testWidgets('FlutterScope.maybeOf return null if there is no FlutterScope above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      Builder(builder: (context) {
        scope = FlutterScope.maybeOf(context);
        return Container();
      })
    );

    expect(scope, null);

  });

  testWidgets('FlutterScope.maybeOf return scope if there is FlutterScope above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<String>(name: 'scopeId', equal: (_) => 'abc'),
        ],
        child: Builder(
          builder: (context) {
            scope = FlutterScope.maybeOf(context);
            return Container();
          },
        ),
      ),
    );

    expect(scope, isNotNull);
    final scopeId = scope?.get<String>(name: 'scopeId');
    expect(scopeId, 'abc');

  });

  testWidgets('FlutterScope.of throw error if there is no FlutterScope above', (tester) async {

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
          contains('There is no scope associated with context'),
        ),
    );

  });

  testWidgets('FlutterScope.of return scope if there is FlutterScope above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<String>(name: 'scopeId', equal: (_) => 'abc'),
        ],
        child: Builder(
          builder: (context) {
            scope = FlutterScope.of(context);
            return Container();
          },
        ),
      ),
    );

    expect(scope, isNotNull);

  });

  testWidgets('FlutterScope.defaultConstructor place an inherited scope in widget tree', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
        child: Builder(builder: (context) {
          scope = FlutterScope.maybeOf(context);
          return Container();
        }),
      ),
    );

    expect(scope, isNotNull);

  });

  testWidgets('FlutterScope.defaultConstructor configure scope failed will throw assert error', (tester) async {

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

  testWidgets('FlutterScope.defaultConstructor configure scope async will throw assert error', (tester) async {

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
          contains("`FlutterScope` default construct is for configuring scope synchronously, please check if all provided configurables are synchronous. if there should be async configurable consider using `FlutterScope.async`."),
        ),
    );

  });

  testWidgets("FlutterScope.defaultConstructor nested scope inherit values from implicitly parent scope", (tester) async {

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

  testWidgets("FlutterScope.defaultConstructor created scope inherit values from explicitly parent scope", (tester) async {

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

  testWidgets('FlutterScope.defaultConstructor dispose registered resources when FlutterScope is removed from widget tree', (tester) async {

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

  testWidgets('FlutterScope.defaultConstructor hot reload with new parent', (tester) async {
    
    final invokes = <String>[];

    final configurable = Configurable((scope) {
      invokes.add('configure');
      scope.addDispose(() {
        invokes.add('dispose');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope(
        parentScope: null,
        configure: [
          configurable,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure',
    ]);

    await tester.pumpWidget(
      FlutterScope(
        parentScope: null, // nothing changed
        configure: [
          configurable,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure',
    ]);

    await tester.pumpWidget(
      FlutterScope(
        parentScope: Scope.root([]) as Scope, // `parentScope` changed
        configure: [
          configurable,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure',
      'dispose',
      'configure',
    ]);

  });

  testWidgets('FlutterScope.defaultConstructor hot reload with new configure when configurable list changed', (tester) async {
    
    final invokes = <String>[];

    final configurable1 = Configurable((scope) {
      invokes.add('configure1');
      scope.addDispose(() {
        invokes.add('dispose1');
      });
    });

    final configurable2 = Configurable((scope) {
      invokes.add('configure2');
      scope.addDispose(() {
        invokes.add('dispose2');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope(
        configure: [
          configurable1,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          configurable2, // configurable list not changed
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          configurable2,
          Configurable((_) {}), // configurable list changed
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure1',
      'dispose1',
      'configure2',
    ]);

  });

  testWidgets('FlutterScope.defaultConstructor hot reload with new configure when hotReloadKey changed', (tester) async {
    
    final invokes = <String>[];

    final configurable1 = Configurable((scope) {
      invokes.add('configure1');
      scope.addDispose(() {
        invokes.add('dispose1');
      });
    });

    final configurable2 = Configurable((scope) {
      invokes.add('configure2');
      scope.addDispose(() {
        invokes.add('dispose2');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope(
        hotReloadKey: null,
        configure: [
          configurable1,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope(
        hotReloadKey: null, // hot reload key not changed
        configure: [
          configurable2,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope(
        hotReloadKey: 1, // hot reload key changed
        configure: [
          configurable2,
        ],
        child: Container(),
      ),
    );
    expect(invokes, [
      'configure1',
      'dispose1',
      'configure2',
    ]);

  });

  testWidgets('InheritedScope place an inherited scope in widget tree using an existing scope', (tester) async {

    final existingScope = await Scope.root([]);

    Scope? scope;

    await tester.pumpWidget(
      InheritedScope(
        scope: existingScope,
        child: Builder(builder: (context) {
          scope = FlutterScope.maybeOf(context);
          return Container();
        }),
      ),
    );

    final isScopeIdentical = identical(existingScope, scope); 
    expect(isScopeIdentical, true);

  });

  testWidgets("InheritedScope won't dispose registered resources when FlutterScope is removed from widget tree", (tester) async {

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
      InheritedScope(
        scope: existingScope,
        child: Container(),
      ),
    );

    expect(disposed, false);
    await tester.pumpWidget(Container());
    expect(disposed, false);

  });

  testWidgets('FlutterScope.async build with asyncScope when resolve scope success', (tester) async {

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

  testWidgets('FlutterScope.async build with asyncScope when resolve scope failed', (tester) async {

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

  testWidgets('FlutterScope.async place an inherited scope in widget tree after scope resolved success', (tester) async {

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

  testWidgets('FlutterScope.async nested scope inherit values from implicitly parent scope', (tester) async {

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

  testWidgets('FlutterScope.async created scope inherit values from explicitly parent scope', (tester) async {
    
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

  testWidgets('FlutterScope.async dispose registered resources when FlutterScope is removed from widget tree', (tester) async {
    
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

  testWidgets('FlutterScope.async defer dispose registered resources when FlutterScope is removed from widget tree and scope is not yet resolved', (tester) async {
    
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

  testWidgets('FlutterScope.async dispose registered resources when resolve scope failed', (tester) async {

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

  testWidgets('FlutterScope.async hot reload with new parent', (tester) async {
    
    final invokes = <String>[];

    final configurable = Configurable((scope) {
      invokes.add('configure');
      scope.addDispose(() {
        invokes.add('dispose');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope.async(
        parentScope: null,
        configure: [
          configurable,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure',
    ]);

    await tester.pumpWidget(
      FlutterScope.async(
        parentScope: null, // nothing changed
        configure: [
          configurable,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure',
    ]);

    await tester.pumpWidget(
      FlutterScope.async(
        parentScope: Scope.root([]) as Scope, // `parentScope` changed
        configure: [
          configurable,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure',
      'dispose',
      'configure',
    ]);
    
  });

  testWidgets('FlutterScope.async hot reload with new configure when configurable list changed', (tester) async {

    final invokes = <String>[];

    final configurable1 = Configurable((scope) {
      invokes.add('configure1');
      scope.addDispose(() {
        invokes.add('dispose1');
      });
    });

    final configurable2 = Configurable((scope) {
      invokes.add('configure2');
      scope.addDispose(() {
        invokes.add('dispose2');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable1,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);
    
    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable2, // configurable list not changed
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable2,
          Configurable((_) {}), // configurable list changed
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
      'dispose1',
      'configure2',
    ]);

  });

  testWidgets('FlutterScope.async hot reload with new configure when hotReloadKey changed', (tester) async {

    final invokes = <String>[];

    final configurable1 = Configurable((scope) {
      invokes.add('configure1');
      scope.addDispose(() {
        invokes.add('dispose1');
      });
    });

    final configurable2 = Configurable((scope) {
      invokes.add('configure2');
      scope.addDispose(() {
        invokes.add('dispose2');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable1,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);
    
    await tester.pumpWidget(
      FlutterScope.async(
        hotReloadKey: null, // hot reload key not changed
        configure: [
          configurable2,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope.async(
        hotReloadKey: 1, // hot reload key changed
        configure: [
          configurable2,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
      'dispose1',
      'configure2',
    ]);

  });

  testWidgets('FlutterScope.async hot reload with new configure, defer dispose old registered resources when old scope is not yet resolved', (tester) async {

    final invokes = <String>[];
    final completer = Completer<void>();

    final configurable1 = Configurable((scope) {
      invokes.add('configure1');
      scope.addDispose(() {
        invokes.add('dispose1');
      });
      return completer.future;
    });

    final configurable2 = Configurable((scope) {
      invokes.add('configure2');
      scope.addDispose(() {
        invokes.add('dispose2');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          configurable1,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
    ]);

    await tester.pumpWidget(
      FlutterScope.async(
        hotReloadKey: 1,
        configure: [
          configurable2,
        ],
        builder: (_, __) => Container(),
      ),
    );
    expect(invokes, [
      'configure1',
      'configure2',
    ]);

    completer.complete(null);
    await Future.microtask(() {});
    expect(invokes, [
      'configure1',
      'configure2',
      'dispose1',
    ]);

  });

  testWidgets('context.scopeOrNull return null if there is no FlutterScope above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      Builder(builder: (context) {
        scope = context.scopeOrNull;
        return Container();
      })
    );

    expect(scope, null);

  });

  testWidgets('context.scopeOrNull return scope if there is FlutterScope above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.async(
        configure: [
          Final<String>(name: 'scopeId', equal: (_) => 'abc'),
        ],
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

  testWidgets('context.scope throw error if there is no FlutterScope above', (tester) async {

    await tester.pumpWidget(
      Builder(builder: (context) {
        final _ = context.scope;
        return Container();
      }),
    );

    expect(
      tester.takeException(),
      isAssertionError
        .having(
          (error) => '$error',
          'description',
          contains('There is no scope associated with context'),
        ),
    );

  });

  testWidgets('context.scope return scope if there is FlutterScope above', (tester) async {

    Scope? scope;

    await tester.pumpWidget(
      FlutterScope.async(
        configure: const [],
        builder: (_, asyncScope) {
          switch (asyncScope.status) {
            case AsyncStatus.loaded:
              return Builder(builder: (context) {
                scope = context.scope;
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

}

