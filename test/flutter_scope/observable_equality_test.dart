
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_scope/src/observable_equality.dart';
import 'package:test/test.dart';

final _observableCreate1 = Observable<int>((_) => Disposable.empty);
final _observableCreate2 = Observable<int>((_) => Disposable.empty);
final _observableMap1 = _observableCreate1.map((it) => it * 2);
final _observableMap2 = _observableCreate2.map((it) => it * 2);

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
}