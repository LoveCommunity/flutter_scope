
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

@internal
@visibleForTesting
class MultiSourcePipeObservableEquality<T, R> 
  implements Equality<MultiSourcePipeObservable<T, R>> {

  MultiSourcePipeObservableEquality(this.getObservableEquality);
  
  final Getter<Equality<Observable<T>>> getObservableEquality;
  late final ListEquality<Observable<T>> listEquality = ListEquality(getObservableEquality());
  
  @override
  bool equals(MultiSourcePipeObservable<T, R> e1, MultiSourcePipeObservable<T, R> e2) {
    return identical(e1, e2)
      || e1.runtimeType == e2.runtimeType
        && listEquality.equals(e1.sources, e2.sources);
  }
  
  @override
  int hash(MultiSourcePipeObservable<T, R> e) {
    return Object.hash(
      e.runtimeType,
      listEquality.hash(e.sources),
    );
  }
  
  @override
  bool isValidKey(Object? o) {
    return o is MultiSourcePipeObservable<T, R>;
  }
}

@internal
@visibleForTesting
class InstanceAsObservableEquality<T, R> 
  implements Equality<InstanceAsObservable<T, R>> {

  const InstanceAsObservableEquality();
  
  @override
  bool equals(InstanceAsObservable<T, R> e1, InstanceAsObservable<T, R> e2) {
    return identical(e1, e2)
      || e1.runtimeType == e2.runtimeType
        && identical(e1.instance, e2.instance);
  }
  
  @override
  int hash(InstanceAsObservable<T, R> e) {
    return Object.hash(
      e.runtimeType,
      e.instance,
    );
  }  

  @override
  bool isValidKey(Object? o) {
    return o is InstanceAsObservable<T, R>;
  }
}