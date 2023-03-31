
// ignore_for_file: prefer_const_declarations

import 'package:flutter/foundation.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_scope/src/configurable_equality.dart';
import 'package:test/test.dart';

final null1 = null;
final null2 = null;
final bool1 = true;
final bool2 = false;
final int1 = 1;
final int2 = 2;
final string1 = 'string1';
final string2 = 'string2';
final object1 = Object();
final object2 = Object();
final final1 = Final<String>(equal: (_) => 'final1');
final final2 = Final<String>(equal: (_) => 'final2');
final configurable1 = Configurable((_) { });
final configurable2 = Configurable((_) { });

final complexConfigurables1 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
];

final complexConfigurables2 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
];
final changedComplexConfigurables1 = [
  Configurable((_) => {}),
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
  Configurable((_) => {}), // length changed
];
final changedComplexConfigurables2 = [
  Final<int>(equal: (_) => 0), // runtimeType changed
  Final<int>(equal: (_) => 0),
  AsyncFinal<String>(equal: (scope) => Future.value('')),
  FinalStates<String>(equal: (_) => States((_) {
    return Disposable.empty;
  })),
  FinalValueNotifier<_Counter, int>(equal: (_) => _Counter()),
];
final changedComplexConfigurables3 = [
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
      [null1, null2],
      [null1, bool2],

      [bool1, bool2],
      [bool1, int2],

      [int1, int2],
      [int1, string2],

      [string1, string2],
      [string1, object2],

      [object1, object2],
      [object1, final2],

      [final1, final2],
      [final1, configurable2],
      
      [configurable1, configurable2],
      [configurable1, null2],
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
      [null1, null2],
      [bool1, bool2],
      [int1, int2],
      [string1, string2],
      [object1, object2],
      [final1, final2],
      [configurable1, configurable2],
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
      [complexConfigurables1, complexConfigurables2],
      [complexConfigurables1, changedComplexConfigurables1],
      [complexConfigurables1, changedComplexConfigurables2],
      [complexConfigurables1, changedComplexConfigurables3],
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
      [complexConfigurables1, complexConfigurables2],
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