
import 'package:flutter/widgets.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('`StatesWidgetBase` assigned states directly', (tester) async {

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

  testWidgets('`StatesWidgetBase` assigned states from scope', (tester) async {

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

  testWidgets('`StatesWidgetBase` start observe states when been inserted into widget tree, stop observe when removed form widget tree', (tester) async {

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

  testWidgets('`StatesWidgetBase` hot reload with new states when `Observable` tree changed', (tester) async {

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

  testWidgets('`StatesWidgetBase` hot reload with new states when `hotReloadKey` changed', (tester) async {

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