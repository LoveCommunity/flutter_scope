
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

}
