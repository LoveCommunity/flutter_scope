
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
    final completer = Completer<void>.sync();

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

    expect(disposed, false);
    completer.complete(null);
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will dispose scope if `dispose` is true, even when scope is resolved after widget been removed', (tester) async {
 
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];
    final completer = Completer<void>.sync();

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

    expect(disposed, false);
    completer.complete(null);
    expect(disposed, true);

  });

  testWidgets('`FlutterScope.scopeEqual` assigned async scope, will not dispose scope if `dispose` is false, even when scope is resolved after widget been removed', (tester) async {
  
    bool disposed = false;
    final List<Async<Scope>> asyncScopes = [];
    final completer = Completer<void>.sync();

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

    expect(disposed, false);
    completer.complete(null);
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

  testWidgets('`_inheritedScope.updateShouldNotify` test coverage', (tester) async {
    final completer = Completer<void>.sync();

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

    await tester.pump();
  });
}

