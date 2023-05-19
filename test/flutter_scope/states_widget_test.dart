
import 'package:flutter/widgets.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('StatesWidgetBase assigned states directly', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        states: variable.asStates(),
        onData: recorded.add,
      ),
    );

    expect(recorded, [
      'a'
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

  });

  testWidgets('StatesWidgetBase assigned states from scope', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
        ],
        child: _StatesWidgetBase<String>(
          onData: recorded.add,
        ),
      ),
    );

    expect(recorded, [
      'a'
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

  });

  testWidgets('StatesWidgetBase start observe states when been inserted into widget tree, stop observe when removed form widget tree', (tester) async {

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
      _StatesWidgetBase<String>(
        states: states,
      )
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

  testWidgets('StatesWidgetBase hot reload with new states when Observable tree changed', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve states');
      return Disposable(() {
        invokes.add('stopObserve states');
      });
    });

    final States<String> similarStates = States((setState) {
      setState('a');
      invokes.add('startObserve similarStates');
      return Disposable(() {
        invokes.add('stopObserve similarStates');
      });
    });

    final States<String> changedStates = States<String>((setState) {
      setState('a');
      invokes.add('startObserve changedStates');
      return Disposable(() {
        invokes.add('stopObserve changedStates');
      });
    }).distinct();

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        states: states,
      )
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        states: similarStates, // use similar states
      )
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        states: changedStates,
      ),
    );
    expect(invokes, [
      'startObserve states',
      'stopObserve states',
      'startObserve changedStates',
    ]);
    
  });

  testWidgets('StatesWidgetBase hot reload with new states when hotReloadKey changed', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve states');
      return Disposable(() {
        invokes.add('stopObserve states');
      });
    });

    final States<String> similarStates = States((setState) {
      setState('a');
      invokes.add('startObserve similarStates');
      return Disposable(() {
        invokes.add('stopObserve similarStates');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        states: states,
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        states: similarStates, // use similar states
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      _StatesWidgetBase<String>(
        hotReloadKey: 1,
        states: similarStates,
      ),
    );
    expect(invokes, [
      'startObserve states',
      'stopObserve states',
      'startObserve similarStates',
    ]);

  });

  testWidgets('StatesBuilder assigned states directly', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      StatesBuilder<String>(
        states: variable.asStates(),
        builder: (context, state) {
          recorded.add(state);
          return Container(); 
        },
      ),
    );

    expect(recorded, [
      'a'
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

  });

  testWidgets('StatesBuilder assigned states from scope', (tester) async {

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
          },
        ),
      ),
    );

    expect(recorded, [
      'a'
    ]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'a',
      'b',
    ]);

    variable.dispose();

  });
 
  testWidgets('StatesBuilder throw error when states is omitted and there is no FlutterScope above', (tester) async {

    await tester.pumpWidget(
      StatesBuilder<String>(
        builder: (context, state) => Container(),
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

  testWidgets('StatesBuilder throw error when states is omitted and it is not exposed from FlutterScope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
        child: StatesBuilder<String>(
          builder: (context, state) => Container(),
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

  testWidgets('StatesBuilder start observe states when been inserted into widget tree, stop observe when removed form widget tree', (tester) async {

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
      StatesBuilder<String>(
        states: states,
        builder: (context, state) => Container(),
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

  testWidgets('StatesBuilder hot reload with new states when Observable tree changed', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve states');
      return Disposable(() {
        invokes.add('stopObserve states');
      });
    });

    final States<String> similarStates = States((setState) {
      setState('a');
      invokes.add('startObserve similarStates');
      return Disposable(() {
        invokes.add('stopObserve similarStates');
      });
    });

    final States<String> changedStates = States<String>((setState) {
      setState('a');
      invokes.add('startObserve changedStates');
      return Disposable(() {
        invokes.add('stopObserve changedStates');
      });
    }).distinct();

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      StatesBuilder<String>(
        states: states,
        builder: (context, state) => Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesBuilder<String>(
        states: similarStates, // use similar states
        builder: (context, state) => Container(),
      )
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesBuilder<String>(
        states: changedStates,
        builder: (context, state) => Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
      'stopObserve states',
      'startObserve changedStates',
    ]);
    
  });

  testWidgets('StatesBuilder hot reload with new states when hotReloadKey changed', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve states');
      return Disposable(() {
        invokes.add('stopObserve states');
      });
    });

    final States<String> similarStates = States((setState) {
      setState('a');
      invokes.add('startObserve similarStates');
      return Disposable(() {
        invokes.add('stopObserve similarStates');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      StatesBuilder<String>(
        states: states,
        builder: (context, state) => Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesBuilder<String>(
        states: similarStates, // use similar states
        builder: (context, state) => Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesBuilder<String>(
        hotReloadKey: 1,
        states: similarStates,
        builder: (context, state) => Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
      'stopObserve states',
      'startObserve similarStates',
    ]);

  });


  testWidgets('StatesListener assigned states directly', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      StatesListener<String>(
        states: variable.asStates(),
        onData: (context, state) {
          recorded.add(state);
        },
        child: Container(),
      ),
    );

    expect(recorded, <String>[]);

    variable.value = 'b';
    await tester.pump();

    expect(recorded, [
      'b',
    ]);

    variable.dispose();

  });

  testWidgets('StatesListener assigned states from scope', (tester) async {

    final List<String> recorded = [];

    final variable = Variable<String>('a');

    await tester.pumpWidget(
      FlutterScope(
        configure: [
          Final<States<String>>(equal: (_) => variable.asStates()),
        ],
        child: StatesListener<String>(
          onData: (context, state) {
            recorded.add(state);
          },
          child: Container(),
        ),
      )
    );

    expect(recorded, <String>[]);

    variable.value = 'b';
    await tester.pump();

    variable.dispose();

  });

  testWidgets('StatesListener skip initial state if skipInitialState is omitted', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      StatesListener<String>(
        states: states,
        onData: (context, state) {
          recorded.add(state);          
        },
        child: Container(),
      )
    );

    expect(recorded, <String>[]);

  });

  testWidgets('StatesListener skip initial state if skipInitialState is true', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      StatesListener<String>(
        states: states,
        skipInitialState: true,
        onData: (context, state) {
          recorded.add(state);          
        },
        child: Container(),
      )
    );

    expect(recorded, <String>[]);

  });

  testWidgets('StatesListener will not skip initial state if skipInitialState is false', (tester) async {

    final List<String> recorded = [];

    final States<String> states = States((setState) {
      setState('a');
      return Disposable.empty;
    });

    await tester.pumpWidget(
      StatesListener<String>(
        states: states,
        skipInitialState: false,
        onData: (context, state) {
          recorded.add(state);          
        },
        child: Container(),
      )
    );

    expect(recorded, [
      'a',
    ]);

  });
  
  testWidgets('StatesListener throw error when states is omitted and there is no FlutterScope above', (tester) async {

    await tester.pumpWidget(
      StatesListener<String>(
        onData: (context, state) {},
        child: Container(),
      )
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

  testWidgets('StatesListener throw error when states is omitted and it is not exposed from FlutterScope', (tester) async {

    await tester.pumpWidget(
      FlutterScope(
        configure: const [],
        child: StatesListener<String>(
          onData: (context, state) {},
          child: Container(),
        ),
      )
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

  testWidgets('StatesListener start observe states when been inserted into widget tree, stop observe when removed form widget tree', (tester) async {

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
      StatesListener<String>(
        states: states,
        onData: (context, state) {},
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

  testWidgets('StatesListener hot reload with new states when Observable tree changed', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve states');
      return Disposable(() {
        invokes.add('stopObserve states');
      });
    });

    final States<String> similarStates = States((setState) {
      setState('a');
      invokes.add('startObserve similarStates');
      return Disposable(() {
        invokes.add('stopObserve similarStates');
      });
    });

    final States<String> changedStates = States<String>((setState) {
      setState('a');
      invokes.add('startObserve changedStates');
      return Disposable(() {
        invokes.add('stopObserve changedStates');
      });
    }).distinct();

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      StatesListener<String>(
        states: states,
        onData: (context, state) {},
        child: Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesListener<String>(
        states: similarStates, // use similar states
        onData: (context, state) {},
        child: Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesListener<String>(
        states: changedStates,
        onData: (context, state) {},
        child: Container(),
      ),
    );
    expect(invokes, [
      'startObserve states',
      'stopObserve states',
      'startObserve changedStates',
    ]);

  });

  testWidgets('StatesListener hot reload with new states when hotReloadKey changed', (tester) async {

    final List<String> invokes = [];

    final States<String> states = States((setState) {
      setState('a');
      invokes.add('startObserve states');
      return Disposable(() {
        invokes.add('stopObserve states');
      });
    });

    final States<String> similarStates = States((setState) {
      setState('a');
      invokes.add('startObserve similarStates');
      return Disposable(() {
        invokes.add('stopObserve similarStates');
      });
    });

    expect(invokes, <String>[]);
    await tester.pumpWidget(
      StatesListener<String>(
        states: states,
        onData: (context, state) {},
        child: Container(),
      )
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesListener<String>(
        states: similarStates, // use similar states
        onData: (context, state) {},
        child: Container(),
      )
    );
    expect(invokes, [
      'startObserve states',
    ]);

    await tester.pumpWidget(
      StatesListener<String>(
        hotReloadKey: 1,
        states: similarStates,
        onData: (context, state) {},
        child: Container(),
      )
    );
    expect(invokes, [
      'startObserve states',
      'stopObserve states',
      'startObserve similarStates',
    ]);

  });
}

class _StatesWidgetBase<T> extends StatesWidgetBase<T> {

  const _StatesWidgetBase({
    super.key,
    super.hotReloadKey,
    super.states,
    this.onData,
  });
  
  final OnData<T>? onData;

  @override
  createState() => _StatesWidgetBaseState<T>();
}

class _StatesWidgetBaseState<T> extends StatesWidgetBaseState<_StatesWidgetBase<T>, T> {

  @override
  void onData(T data) {
    widget.onData?.call(data);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}