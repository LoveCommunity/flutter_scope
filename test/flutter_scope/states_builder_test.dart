
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

    expect(invokes, []);
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

}
