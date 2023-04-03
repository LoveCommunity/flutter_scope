
// ignore_for_file: prefer_const_declarations

import 'package:flutter/foundation.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_scope/src/configurable_equality.dart';
import 'package:test/test.dart';

final _null1 = null;
final _null2 = null;
final _bool1 = true;
final _bool2 = false;
final _int1 = 1;
final _int2 = 2;
final _string1 = 'string1';
final _string2 = 'string2';
final _object1 = Object();
final _object2 = Object();
final _final1 = Final<String>(equal: (_) => 'final1');
final _final2 = Final<String>(equal: (_) => 'final2');
final _configurable1 = Configurable((_) { });
final _configurable2 = Configurable((_) { });

final _complexConfigurables1 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
];

final _complexConfigurables2 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
];
final _changedComplexConfigurables1 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
  Configurable((_) => {}), // length changed
];
final _changedComplexConfigurables2 = [
  Final<int>(equal: (_) => 0), // runtimeType changed
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
];
final _changedComplexConfigurables3 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalChangeNotifier<_Counter>(equal: (_) => _Counter()), // runtimeType changed
];

void main() {

  test('`runtimeTypeEquality.isValidKey` verify objects', () {
    
    const equality = RuntimeTypeEquality();

    final objects = [
      null,
      true,
      0,
      '',
      Object(),
        
      Final<String>(equal: (_) => ''),
      Configurable((_) { }),
    ];

    final expected = [
      true,
      true,
      true,
      true,
      true,

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

  test('`runtimeTypeEquality.equals` comparing objects for equality', () {

    const equality = RuntimeTypeEquality();
    
    final objects = [
      [_null1, _null2],
      [_null1, _bool2],

      [_bool1, _bool2],
      [_bool1, _int2],

      [_int1, _int2],
      [_int1, _string2],

      [_string1, _string2],
      [_string1, _object2],

      [_object1, _object2],
      [_object1, _final2],

      [_final1, _final2],
      [_final1, _configurable2],
      
      [_configurable1, _configurable2],
      [_configurable1, _null2],
    ];

    final expected = [
      true,
      false,

      true,
      false,

      true,
      false,

      true,
      false,

      true,
      false,

      true,
      false,

      true,
      false,
    ];
    
    expect(
      objects
        .map((list) => equality.equals(list[0], list[1]))
        .toList(), 
      expected
    );

  });

  test('`runtimeTypeEquality.hash` return same value when objects are equal', () {

    const equality = RuntimeTypeEquality();

    final objects = [
      [_null1, _null2],
      [_bool1, _bool2],
      [_int1, _int2],
      [_string1, _string2],
      [_object1, _object2],
      [_final1, _final2],
      [_configurable1, _configurable2],
    ];

    final expected = [
      true,
      true,
      true,
      true,
      true,
      true,
      true,
    ];

    expect(
      objects
        .map((list) => equality.hash(list[0]) == equality.hash(list[1]))
        .toList(),
      expected,
    );
    
  });

  test('`configurableListEquality.isValidKey` verify objects', () {

    final configurables = [
      null,
      true,
      0,
      '',
      Object(),
      Final<String>(equal: (_) => ''),

      <Configurable>[],
      [
        Configurable((_) => {})
      ],
      [
        Final<int>(equal: (_) => 0),
        AsyncFinal<String>(equal: (scope) => Future.value('')),
      ],
      [
        FinalStates<String>(equal: (_) => States((_) {
          return Disposable.empty;
        })),
        FinalValueNotifier<_Counter, int>(equal: (_) => _Counter())
      ],
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
      true,
      true,
    ];

    expect(
      configurables
        .map(configurableListEquality.isValidKey)
        .toList(),
      expected,
    );

  });

  test('`configurableListEquality.equals` comparing objects for equality', () {

    final configurables = [
      [_complexConfigurables1, _complexConfigurables2],
      [_complexConfigurables1, _changedComplexConfigurables1],
      [_complexConfigurables1, _changedComplexConfigurables2],
      [_complexConfigurables1, _changedComplexConfigurables3],
    ];

    final expected = [
      true,
      false,
      false,
      false,
    ];

    expect(
      configurables
        .map((list) => configurableListEquality.equals(list[0], list[1]))
        .toList(),
      expected,
    );

  });

  test('`configurableListEquality.hash` return same value when objects are equal', () {

    final configurables = [
      [_complexConfigurables1, _complexConfigurables2],
    ];

    final expected = [
      true,
    ];

    expect(
      configurables
        .map((list) => 
          configurableListEquality.hash(list[0]) == configurableListEquality.hash(list[1])
        ).toList(),
      expected,
    );

  });
}

class _Counter extends ValueNotifier<int> {
  _Counter(): super(0);
}