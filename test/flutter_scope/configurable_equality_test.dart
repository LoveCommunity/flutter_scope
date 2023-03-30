
// ignore_for_file: prefer_const_declarations

import 'package:dart_scope/dart_scope.dart';
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
}