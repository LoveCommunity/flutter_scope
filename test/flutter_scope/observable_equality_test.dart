
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

final _observableCombineEmpty = Observable.combine<int, int>(
  sources: [],
  combiner: (items) => items.length,
);
final _observableZipEmpty1 = _ObservableZip<int, int>(
  sources: [],
);
final _observableZipEmpty2 = _ObservableZip<int, int>(
  sources: [],
);
final _observableZipCreate1 = _ObservableZip<int, int>(
  sources: [
    _observableCreate1,
  ],
);
final _observableZipCreate2 = _ObservableZip<int, int>(
  sources: [
    _observableCreate2,
  ],
);
final _observableZipMap1 = _ObservableZip<int, int>(
  sources: [
    _observableMap1,
  ],
);
final _observableZipMap2 = _ObservableZip<int, int>(
  sources: [
    _observableMap2,
  ],
);
final _observableZipCreateCreate1 = _ObservableZip<int, int>(
  sources: [
    _observableCreate1,
    _observableCreate1,
  ],
);
final _observableZipCreateCreate2 = _ObservableZip<int, int>(
  sources: [
    _observableCreate2,
    _observableCreate2,
  ],
);
final _observableZipCreateMap1 = _ObservableZip<int, int>(
  sources: [
    _observableCreate1,
    _observableMap1,
  ],
);
final _observableZipCreateMap2 = _ObservableZip<int, int>(
  sources: [
    _observableCreate2,
    _observableMap2,
  ],
);
final _observableZipMapMap1 = _ObservableZip<int, int>(
  sources: [
    _observableMap1,
    _observableMap1,
  ],
);
final _observableZipMapMap2 = _ObservableZip<int, int>(
  sources: [
    _observableMap2,
    _observableMap2,
  ],
);

final _object1 = Object();
final _object2 = Object();
final _anotherObject1AsObservable = _AnotherObjectAsObservable<int>(_object1);
final _object1AsObservable1 = _ObjectAsObservable<int>(_object1);
final _object1AsObservable2 = _ObjectAsObservable<int>(_object1);
final _object2AsObservable1 = _ObjectAsObservable<int>(_object2);
final _object2AsObservable2 = _ObjectAsObservable<int>(_object2);

final _complexObservable1 = _ObservableZip<int, int>(
  sources: [
    Observable<int>((_) => Disposable.empty)
      .map((it) => it * 2),
    _ObjectAsObservable<int>(_object1),
  ],
);
final _complexObservable2 = _ObservableZip<int, int>(
  sources: [
    Observable<int>((_) => Disposable.empty)
      .map((it) => it * 2),
    _ObjectAsObservable<int>(_object1),
  ],
);
final _changedComplexObservable1 = _ObservableZip<Object, Object>( // generic type changed
  sources: [
    Observable<int>((_) => Disposable.empty)
      .map((it) => it * 2),
    _ObjectAsObservable<int>(_object1),
  ],
);
final _changedComplexObservable2 = Observable.combine<int, int>( // runtime type changed
  sources: [
    Observable<int>((_) => Disposable.empty)
      .map((it) => it * 2),
    _ObjectAsObservable<int>(_object1),
  ],
  combiner: (items) => items.length,
);
final _changedComplexObservable3 = _ObservableZip<int, int>(
  sources: [
    _ObjectAsObservable<int>(_object1)  // runtime type changed
      .map((it) => it * 2),
    _ObjectAsObservable<int>(_object1),
  ],
);
final _changedComplexObservable4 = _ObservableZip<int, int>(
  sources: [
    Observable<int>((_) => Disposable.empty)
      .distinct(),                      // runtime type changed
    _ObjectAsObservable<int>(_object1),
  ],
);
final _changedComplexObservable5 = _ObservableZip<int, int>(
  sources: [
    Observable<int>((_) => Disposable.empty)
      .map((it) => it * 2),
    _ObjectAsObservable<int>(_object2), // object changed
  ],
);
final _changedComplexObservable6 = _ObservableZip<int, int>(
  sources: [
    Observable<int>((_) => Disposable.empty)
      .map((it) => it * 2),
    _AnotherObjectAsObservable<int>(_object1), // runtime type changed
  ],
);

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


  test('`multiSourceObservableEquality.isValidKey` verify objects', () {

    final equality = MultiSourcePipeObservableEquality<int, int>(
      () => const FallbackObservableEquality<int>()
    );

    final objects = [
      true,
      0,
      '',
      Observable<bool>((_) => Disposable.empty),
      Observable<int>((_) => Disposable.empty),
      Observable<int>((_) => Disposable.empty)
        .map((it) => it * 2),
      _ObservableZip<bool, int>(
        sources: [],
      ),
      _ObservableZip<int, int>(
        sources: [],
      ),
    ];

    final expected = [
      false,
      false,
      false,
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

  test('`multiSourceObservableEquality.equals` comparing observables for equality', () {

    final equality = MultiSourcePipeObservableEquality<int, int>(
      () => const FallbackObservableEquality<int>()
    );

    final observables = [
      [_observableZipEmpty1, _observableCombineEmpty],
      [_observableZipEmpty1, _observableZipEmpty2],
      [_observableZipEmpty1, _observableZipCreate2],

      [_observableZipCreate1, _observableZipCreate2],
      [_observableZipCreate1, _observableZipMap2],
      [_observableZipMap1, _observableZipMap2],
      [_observableZipMap1, _observableZipMapMap2],

      [_observableZipCreateCreate1, _observableZipCreateCreate2],
      [_observableZipCreateCreate1, _observableZipCreateMap2],
      [_observableZipCreateCreate1, _observableZipMapMap2],
      [_observableZipCreateMap1, _observableZipCreateMap2],
      [_observableZipCreateMap1, _observableZipMapMap2],
      [_observableZipMapMap1, _observableZipMapMap2],
    ];

    final expected = [
      false,
      true,
      false,

      true,
      false,
      true,
      false,

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
          final observable1 = list[0] as MultiSourcePipeObservable<int, int>;
          final observable2 = list[1] as MultiSourcePipeObservable<int, int>;
          return equality.equals(observable1, observable2);
        })
        .toList(),
      expected,
    ); 

  });

  test('`multiSourceObservableEquality.hash` return same value when observables are equal', () {

    final equality = MultiSourcePipeObservableEquality<int, int>(
      () => const FallbackObservableEquality<int>()
    );

    final observables = [
      [_observableZipEmpty1, _observableZipEmpty2],
      [_observableZipCreate1, _observableZipCreate2],
      [_observableZipMap1, _observableZipMap2],
      [_observableZipCreateCreate1, _observableZipCreateCreate2],
      [_observableZipCreateMap1, _observableZipCreateMap2],
      [_observableZipMapMap1, _observableZipMapMap2],
    ];

    final expected = [
      true,
      true,
      true,
      true,
      true,
      true,
    ];

    expect(
      observables
        .map((list) {
          final observable1 = list[0];
          final observable2 = list[1];
          return equality.hash(observable1) == equality.hash(observable2);
        })
        .toList(),
      expected,
    );

  });

  test('`instanceAsObservableEquality.isValidKey` verify objects', () {

    const equality = InstanceAsObservableEquality<Object, int>();

    final objects = [
      true,
      0,
      '',
      Observable<int>((_) => Disposable.empty),
      Observable<int>((_) => Disposable.empty)
        .map((it) => it * 2),
      _ObservableZip<int, int>(
        sources: [],
      ),
      _ObjectAsObservable<bool>(Object()),
      _ObjectAsObservable<int>(Object()),
    ];

    final expected = [
      false,
      false,
      false,
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

  test('`instanceAsObservableEquality.equals` comparing observables for equality', () {

    const equality = InstanceAsObservableEquality<Object, int>();

    final observables = [
      [_object1AsObservable1, _anotherObject1AsObservable],
      [_object1AsObservable1, _object1AsObservable2],
      [_object1AsObservable1, _object2AsObservable2],
      [_object2AsObservable1, _object2AsObservable2],
    ];

    final expected = [
      false,
      true,
      false,
      true,
    ];

    expect(
      observables
        .map((list) {
          final observable1 = list[0];
          final observable2 = list[1];
          return equality.equals(observable1, observable2);
        })
        .toList(),
      expected,
    );

  });

  test('`instanceAsObservableEquality.hash` return same value when observables are equal', () {

    const equality = InstanceAsObservableEquality<Object, int>();

    final observables = [
      [_object1AsObservable1, _object1AsObservable2],
      [_object2AsObservable1, _object2AsObservable2],
    ];

    final expected = [
      true,
      true,
    ];

    expect(
      observables
        .map((list) {
          final observable1 = list[0];
          final observable2 = list[1]; 
          return equality.hash(observable1) == equality.hash(observable2);
        })
        .toList(),
      expected,
    );

  });
  
  test('deepObservableEquality.isValidKey verify objects', () {

    final objects = [
      true,
      0,
      '',

      Observable<void>((_) => Disposable.empty),
      Observable<bool>((_) => Disposable.empty),
      Observable<int>((_) => Disposable.empty),

      Observable<int>((_) => Disposable.empty)
        .map((it) => it * 2),
      _ObservableZip<bool, int>(
        sources: [],
      ),
      _ObservableZip<int, int>(
        sources: [],
      ),

      _ObjectAsObservable<bool>(Object()),
      _ObjectAsObservable<int>(Object()),
    ];

    final expected = [
      false,
      false,
      false,

      true,
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
        .map(deepObservableEquality.isValidKey)
        .toList(),
      expected,
    );
  });

  test('`deepObservableEquality.equals` comparing observables for equality', () {
    
    final observables = [
      [_complexObservable1, _complexObservable2],
      [_complexObservable1, _changedComplexObservable1],
      [_complexObservable1, _changedComplexObservable2],
      [_complexObservable1, _changedComplexObservable3],
      [_complexObservable1, _changedComplexObservable4],
      [_complexObservable1, _changedComplexObservable5],
      [_complexObservable1, _changedComplexObservable6],
    ];

    final expected = [
      true,
      false,
      false,
      false,
      false,
      false,
      false,
    ];

    expect(
      observables
        .map((list) {
          final observable1 = list[0] as Observable<Object?>;
          final observable2 = list[1] as Observable<Object?>;
          return deepObservableEquality.equals(observable1, observable2);
        })
        .toList(),
      expected,
    );

  });

  test('`deepObservableEquality.hash` return same value when observables are equal', () {

    final observables = [
      [_observableCreate1, _observableCreate1],
      [_observableCreate1, _observableCreate2],

      [_observableMap1, _observableMap2],
      [_observableDistinct1, _observableDistinct2],
      [_observableMapDistinct1, _observableMapDistinct2],

      [_observableZipEmpty1, _observableZipEmpty2],
      [_observableZipCreate1, _observableZipCreate2],
      [_observableZipMap1, _observableZipMap2],
      [_observableZipCreateCreate1, _observableZipCreateCreate2],
      [_observableZipCreateMap1, _observableZipCreateMap2],
      [_observableZipMapMap1, _observableZipMapMap2],

      [_object1AsObservable1, _object1AsObservable2],
      [_object2AsObservable1, _object2AsObservable2],

      [_complexObservable1, _complexObservable2],
    ];

    final expected = [
      true,
      true,

      true,
      true,
      true,

      true,
      true,
      true,
      true,
      true,
      true,

      true,
      true,

      true,
    ];

    expect(
      observables
        .map((list) => 
          deepObservableEquality.hash(list[0]) == deepObservableEquality.hash(list[1])
        )
        .toList(),
      expected,
    );

  });
 
}

class _ObservableZip<T, R> extends MultiSourcePipeObservable<T, R> {

  _ObservableZip({
    required super.sources,
  });

  @override
  Disposable observe(OnData<R> onData) {
    throw UnimplementedError();
  }
}

class _ObjectAsObservable<R> extends InstanceAsObservable<Object, R> {
  _ObjectAsObservable(super.instance);

  @override
  Disposable observe(OnData<R> onData) {
    throw UnimplementedError();
  }
}

class _AnotherObjectAsObservable<R> extends InstanceAsObservable<Object, R> {
  _AnotherObjectAsObservable(super.instance);

  @override
  Disposable observe(OnData<R> onData) {
    throw UnimplementedError();
  }
}