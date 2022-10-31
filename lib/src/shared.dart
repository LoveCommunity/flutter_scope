
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:dart_scope/dart_scope.dart';

import 'flutter_scope.dart';

typedef FlutterEqual<T> = T Function(BuildContext context);

@internal
FlutterEqual<States<T>> contextGetStates<T>({ 
  required Object? name,
}) {
  return (context) => context.scope
    .get<States<T>>(name: name);
}

@internal
FlutterEqual<States<R>> contextConvertStates<T, R>({ 
  required Object? name,
  required R Function(T state) convert,
  required Equals<R>? equals,
}) {
  return (context) => context.scope
    .get<States<T>>(name: name)
    .convert<R>(
      convert,
      equals: equals,
    );
}
