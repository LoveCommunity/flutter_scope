
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scope/flutter_scope.dart';

void main() {

  testWidgets('`StatesBuilder.statesEqual` assigned states directly', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      StatesBuilder<String>.statesEqual(
        statesEqual: (_) => variable.asStates(),
        builder: (context, state) {
          recorded.add(state);
          return Container();
        }
      ),
    );

    expect(recorded, [
      'a',
    ]);
    
    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

  });

  testWidgets('`StatesBuilder.statesEqual` assigned states from scope', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
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
    
    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

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

  testWidgets('`StatesBuilder.defaultConstructor` resolve states success', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
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
    
    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

  });

  testWidgets('`StatesBuilder.defaultConstructor` resolve states success with name', (tester) async {
 
    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(name: 'states', equal: (_) => variable.asStates()),
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
    
    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

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
          contains('There is no scope associated with context'),
        ),
    );

  });

  testWidgets('`StatesBuilder.defaultConstructor` throw error if states not exposed in scope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
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

  testWidgets('`StatesBuilderConvert` resolve states success', (tester) async {

    final List<String> recorded = [];
    
    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
        ],
        child: StatesBuilderConvert<String, String>(
          convert: (state) => '1$state',
          builder: (context, value) {
            recorded.add(value);
            return Container();
          },
        ),
      ),
    );

    expect(recorded, [
      '1a',
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      '1a',
      '1b',
    ]);

    variable.dispose();

  });

  testWidgets('`StatesBuilderConvert` resolve states success with name', (tester) async {
 
    final List<String> recorded = [];
    
    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(name: 'states', equal: (_) => variable.asStates()),
        ],
        child: StatesBuilderConvert<String, String>(
          name: 'states',
          convert: (state) => '1$state',
          builder: (context, value) {
            recorded.add(value);
            return Container();
          },
        ),
      ),
    );

    expect(recorded, [
      '1a',
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      '1a',
      '1b',
    ]);

    variable.dispose();

 });

  testWidgets('`StatesBuilderConvert` using default `equals`', (tester) async {

    final List<String> recorded = [];
    
    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
        ],
        child: StatesBuilderConvert<String, String>(
          convert: (state) => '1$state',
          builder: (context, value) {
            recorded.add(value);
            return Container();
          },
        ),
      ),
    );

    expect(recorded, [
      '1a',
    ]);

    variable.value = 'a';
    await tester.pump();

    expect(recorded, [
      '1a',
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      '1a',
      '1b',
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      '1a',
      '1b',
    ]);

    variable.dispose();

  });

  testWidgets('`StatesBuilderConvert` using custom `equals`', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
        ],
        child: StatesBuilderConvert<String, String>(
          convert: (state) => '1$state',
          equals: (value1, value2) => value1.length == value2.length,
          builder: (context, value) {
            recorded.add(value);
            return Container();
          },
        ),
      ),
    );

    expect(recorded, [
      '1a',
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      '1a',
    ]);

    variable.value = 'aa';
    await tester.pump();

    expect(recorded, [
      '1a',
      '1aa',
    ]);

    variable.value = 'bb';
    await tester.pump();

    expect(recorded, [
      '1a',
      '1aa',
    ]);

    variable.dispose();

  });

  testWidgets('`StatesBuilderConvert` throw error if there is no `FlutterScope` above', (tester) async {
    
    await tester.pumpWidget(
      StatesBuilderConvert<String, String>(
        convert: (state) => '1$state',
        builder: (_, __) => Container(),
      ),
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

  testWidgets('`StatesBuilderConvert` throw error if states not exposed in scope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
        child: StatesBuilderConvert<String, String>(
          convert: (state) => '1$state',
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
