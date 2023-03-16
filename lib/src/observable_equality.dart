
import 'package:meta/meta.dart';
import 'package:dart_scope/dart_scope.dart';
import 'package:collection/collection.dart';

@internal
@visibleForTesting
class FallbackObservableEquality<T> implements Equality<Observable<T>> {
  
  const FallbackObservableEquality();

  @override
  bool equals(Observable<T> e1, Observable<T> e2) {
    return identical(e1, e2)
      || e1.runtimeType == e2.runtimeType;
  }

  @override
  int hash(Observable<T> e) {
    return e.runtimeType.hashCode;
  }

  @override
  bool isValidKey(Object? o) {
    return o is Observable<T>;
  } 
}

@internal
@visibleForTesting
class PipeObservableEquality<T, R> implements Equality<PipeObservable<T, R>> {
  const PipeObservableEquality(this.getObservableEquality);

  final Getter<Equality<Observable<T>>> getObservableEquality;

  @override
  bool equals(PipeObservable<T, R> e1, PipeObservable<T, R> e2) {
    return identical(e1, e2)
      || e1.runtimeType == e2.runtimeType
        && getObservableEquality().equals(e1.source, e2.source);
  }

  @override
  int hash(PipeObservable<T, R> e) {
    return Object.hash(
      e.runtimeType,
      getObservableEquality().hash(e.source),
    );
  }

  @override
  bool isValidKey(Object? o) {
    return o is PipeObservable<T, R>;
  }
  
}