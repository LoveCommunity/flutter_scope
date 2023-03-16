
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_scope/src/observable_equality.dart';
import 'package:test/test.dart';

final _observableCreate1 = Observable<int>((_) => Disposable.empty);
final _observableCreate2 = Observable<int>((_) => Disposable.empty);
final _observableMap1 = _observableCreate1.map((it) => it * 2);
final _observableMap2 = _observableCreate2.map((it) => it * 2);
final _observableDistinct1 = _observableCreate1.distinct();
final _observableDistinct2 = _observableCreate2.distinct();
final _observableMapDistinct1 = _observableMap1.distinct();
final _observableMapDistinct2 = _observableMap2.distinct();

void main() {

  test('`fallbackObservableEquality.isValidKey` verify objects', () {

    const equality = FallbackObservableEquality<int>();
    
    final objects = [
      true,
      0,
      '',
      Observable<bool>((_) => Disposable.empty),
      Observable<int>((_) => Disposable.empty),
    ];

    final expected = [
      false,
      false,
      false,
      false,
      true,
    ];

    expect(
      objects
        .map(equality.isValidKey)
        .toList(),
      expected,
    );

  });

  test('`fallbackObservableEquality.equals` comparing observables for equality', () {

    const equality = FallbackObservableEquality<int>();

    final observables = [
      [_observableCreate1, _observableCreate1],
      [_observableCreate1, _observableCreate2],
      [_observableCreate1, _observableMap1],
      [_observableCreate2, _observableMap2],
      [_observableMap1, _observableMap2],
    ];

    final expected = [
      true,
      true,
      false,
      false,
      true,
    ];

    expect(
      observables
        .map((list) => equality.equals(list[0], list[1]))
        .toList(),
      expected,
    );

  });

  test('`fallbackObservableEquality.hash` return same value when observables are equal', () {

    const equality = FallbackObservableEquality<int>();

    final observables = [
      [_observableCreate1, _observableCreate1],
      [_observableCreate1, _observableCreate2],
      [_observableMap1, _observableMap2],
    ];

    final expected = [
      true,
      true,
      true,
    ];

    expect(
      observables
        .map((list) => equality.hash(list[0]) == equality.hash(list[1]))
        .toList(),
      expected,
    );

  });

  test('`pipeObservableEquality.isValidKey` verify objects', () {

    final equality = PipeObservableEquality<int, int>(
      () => const FallbackObservableEquality<int>()
    );

    final objects = [
      true,
      0,
      '',
      Observable<bool>((_) => Disposable.empty),
      Observable<int>((_) => Disposable.empty),
      Observable<bool>((_) => Disposable.empty)
        .map((it) => it ? 1 : 0),
      Observable<int>((_) => Disposable.empty)
        .map((it) => it * 2),
      Observable<int>((_) => Disposable.empty)
        .map((it) => it * 2)
        .distinct(),
    ];

    final expected = [
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      true,
    ];

    expect(
      objects
        .map(equality.isValidKey)
        .toList(),
      expected,
    );
  });

  test('`pipeObservableEquality.equals` comparing observables for equality', () {

    final equality = PipeObservableEquality<int, int>(
      () => const FallbackObservableEquality<int>()
    );

    final observables = [
      [_observableMap1, _observableMap2],
      [_observableMap1, _observableDistinct2],
      [_observableMap1, _observableMapDistinct2],
      [_observableDistinct1, _observableDistinct2],
      [_observableDistinct1, _observableMapDistinct2],
      [_observableMapDistinct1, _observableMapDistinct2],
    ];

    final expected = [
      true,
      false,
      false,
      true,
      false,
      true,
    ];
    
    expect(
      observables
        .map((list) {
          final observable1 = list[0] as PipeObservable<int, int>;
          final observable2 = list[1] as PipeObservable<int, int>;
          return equality.equals(observable1, observable2);
        })
        .toList(),
      expected,
    );

  });

  test('`pipeObservableEquality.hash` return same value when observables are equal', () {

    final equality = PipeObservableEquality<int, int>(
      () => const FallbackObservableEquality<int>()
    );

    final observables = [
      [_observableMap1, _observableMap2],
      [_observableDistinct1, _observableDistinct2],
      [_observableMapDistinct1, _observableMapDistinct2],
    ];

    final expected = [
      true,
      true,
      true,
    ];

    expect(
      observables
        .map((list) {
          final observable1 = list[0] as PipeObservable<int, int>;
          final observable2 = list[1] as PipeObservable<int, int>;
          return equality.hash(observable1) == equality.hash(observable2);
        })
        .toList(),
      expected,
    );
    
  });
}