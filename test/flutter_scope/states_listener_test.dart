
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:dart_scope/dart_scope.dart';

void main() {

  testWidgets('`StatesListner.statesEqual` assigned states directly', (tester) async {
  
    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      StatesListener<String>.statesEqual(
        statesEqual: (_) => subject.asStates(),
        onData: (context, state) {
          recorded.add(state);
        },
        child: Container(),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListner.statesEqual` assigned states from scope', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesListener<String>.statesEqual(
          statesEqual: (context) => FlutterScope.of(context).get(),
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListner.statesEqual` skip initial state if `skipInitialState` is omitted', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      StatesListener<String>.statesEqual(
        statesEqual: (_) => states,
        onData: (context, state) {
          invokes.add(state);
        },
        child: Container(),
      ),
    );

    expect(invokes, <String>[]);

  });

  testWidgets('`StatesListner.statesEqual` skip initial state if `skipInitialState` is true', (tester) async {
 
    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      StatesListener<String>.statesEqual(
        statesEqual: (_) => states,
        skipInitialState: true,
        onData: (context, state) {
          invokes.add(state);
        },
        child: Container(),
      ),
    );

    expect(invokes, <String>[]);

  });

  testWidgets('`StatesListner.statesEqual` will not skip initial state if `skipInitialState` is false', (tester) async {
 
    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      StatesListener<String>.statesEqual(
        statesEqual: (_) => states,
        skipInitialState: false,
        onData: (context, state) {
          invokes.add(state);
        },
        child: Container(),
      ),
    );

    expect(invokes, [
      'a',
    ]);

  });

  testWidgets('`StatesListner.statesEqual` start observe states when widget been inserted into tree, stop observe states when widget been removed from tree', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve');
      return Disposable(() {
        invokes.add('stopObserve');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      StatesListener<String>.statesEqual(
        statesEqual: (_) => states,
        onData: (_, __) { },
        child: Container(),
      ),
    );
    expect(invokes, [
      'startObserve',
    ]);

    await tester.pumpWidget(Container());
    expect(invokes, [
      'startObserve',
      'stopObserve',
    ]);

  });
 
  testWidgets('`StatesListener.defaultConstructor` resolve states success', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesListener<String>(
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListener.defaultConstructor` resolve states success with name', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(name: 'states', equal: (_) => subject.asStates()),
        ],
        child: StatesListener<String>(
          name: 'states',
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListener.defaultConstructor` throw error if there is no `FlutterScope` above', (tester) async {

    await tester.pumpWidget(
      StatesListener<String>(
        onData: (_, __) {},
        child: Container(),
      ),
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

  testWidgets('`StatesListener.defaultConstructor` throw error if states not exposed in scope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
        child: StatesListener<String>(
          onData: (_, __) {},
          child: Container(),
        ),
      ),
    );
    
    expect(
      tester.takeException(),
      isA<ScopeValueNotExposedError<States<String>>>()
        .having(
          (error) => '$error',
          'description',
          contains('`States<String>` is not exposed in current scope'),
        ),
    );

  });

  testWidgets('`StatesListener.defaultConstructor` skip initial state if `skipInitialState` is omitted', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => states),
        ],
        child: StatesListener<String>(
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

  });

  testWidgets('`StatesListener.defaultConstructor` skip initial state if `skipInitialState` is true', (tester) async {
 
    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => states),
        ],
        child: StatesListener<String>(
          skipInitialState: true,
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

 });

  testWidgets('`StatesListener.defaultConstructor` will not skip initial state if `skipInitialState` is false', (tester) async {
  
    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => states),
        ],
        child: StatesListener<String>(
          skipInitialState: false,
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, [
      'a',
    ]);

  });

  testWidgets('`StatesListenerSelect` resolve states success', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';

    expect(recorded, [
      '1b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListenerSelect` resolve states success with name', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(name: 'states', equal: (_) => subject.asStates()),
        ],
        child: StatesListenerSelect<String, String>(
          name: 'states',
          select: (state) => '1$state',
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';

    expect(recorded, [
      '1b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListenerSelect` throw error if there is no `FlutterScope` above', (tester) async {

    await tester.pumpWidget(
      StatesListenerSelect<String, String>(
        select: (state) => '1$state',
        onData: (_, __) {},
        child: Container(),
      ),
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

  testWidgets('`StatesListenerSelect` throw error if value not exposed in scope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          onData: (_, __) {},
          child: Container(),
        ),
      ),
    );

    expect(
      tester.takeException(),
      isA<ScopeValueNotExposedError<States<String>>>()
        .having(
          (error) => '$error',
          'description',
          contains('`States<String>` is not exposed in current scope'),
        ),
    );

  });

  testWidgets('`StatesListenerSelect` using default `equals`', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'a';

    expect(recorded, <String>[]);

    subject.value = 'b';

    expect(recorded, [
      '1b',
    ]);

    subject.value = 'b';

    expect(recorded, [
      '1b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListenerSelect` using custom `equals`', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          equals: (value1, value2) => value1.length == value2.length,
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

    subject.value = 'b';

    expect(recorded, <String>[]);

    subject.value = 'aa';

    expect(recorded, [
      '1aa',
    ]);

    subject.value = 'bb';

    expect(recorded, [
      '1aa',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesListenerSelect` skip initial state if `skipInitialState` is omitted', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });
    
    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => states),
        ],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

  });

  testWidgets('`StatesListenerSelect` skip initial state if `skipInitialState` is true', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => states),
        ],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          skipInitialState: true,
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, <String>[]);

  });

  testWidgets('`StatesListenerSelect` will not skip initial state if `skipInitialState` is false', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => states),
        ],
        child: StatesListenerSelect<String, String>(
          select: (state) => '1$state',
          skipInitialState: false,
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      ),
    );

    expect(recorded, [
      '1a',
    ]);

  });

}
