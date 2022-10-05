
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:dart_scope/dart_scope.dart';

void main() {

  testWidgets('`StatesBuilder.statesEqual` assigned states directly', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      StatesBuilder<String>.statesEqual(
        statesEqual: (_) => subject.asStates(),
        builder: (context, state) {
          recorded.add(state);
          return Container();
        }
      ),
    );

    expect(recorded, [
      'a',
    ]);
    
    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesBuilder.statesEqual` assigned states from scope', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesBuilder<String>.statesEqual(
          statesEqual: (context) => FlutterScope.maybeOf(context)!.get(),
          builder: (context, state) {
            recorded.add(state);
            return Container();
          }
        ),
      ),
    );

    expect(recorded, [
      'a',
    ]);
    
    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    subject.dispose();

  });

  testWidgets("`StatesBuilder.statesEqual` start observe states when widget been inserted into tree, stop observe states when widget been removed from tree", (tester) async {

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
      StatesBuilder<String>.statesEqual(
        statesEqual: (_) => states,
        builder: (context, state) {
          return Container();
        }
      ),
    );
    expect(invokes, [
      'startObserve',
    ]);

    await tester.pumpWidget(Container());
    expect(invokes, [
      'startObserve',
      'stopObserve'
    ]);

  });

  testWidgets('`StatesBuilder.defaultConstructor` assign states success', (tester) async {

    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => subject.asStates()),
        ],
        child: StatesBuilder<String>(
          builder: (context, state) {
            recorded.add(state);
            return Container();
          }
        ),
      ),
    );

    expect(recorded, [
      'a',
    ]);
    
    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesBuilder.defaultConstructor` assign states success with name', (tester) async {
 
    final List<String> recorded = [];

    final subject = ValueSubject<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(name: 'states', equal: (_) => subject.asStates()),
        ],
        child: StatesBuilder<String>(
          name: 'states',
          builder: (context, state) {
            recorded.add(state);
            return Container();
          }
        ),
      ),
    );

    expect(recorded, [
      'a',
    ]);
    
    subject.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    subject.dispose();

  });

  testWidgets('`StatesBuilder.defaultConstructor` throw error if there is no `FlutterScope` above', (tester) async {

    await tester.pumpWidget(
      StatesBuilder<String>(
        builder: (_, __) => Container(),
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

  testWidgets('`StatesBuilder.defaultConstructor` throw error if value not exposed in scope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: [],
        child: StatesBuilder<String>(
          builder: (_, __) => Container(),
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

}
