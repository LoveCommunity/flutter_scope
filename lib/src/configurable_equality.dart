
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@internal
class RuntimeTypeEquality implements Equality<Object?> {
  
  const RuntimeTypeEquality();
  
  @override
  bool equals(Object? e1, Object? e2) {
    return identical(e1, e2)
      || e1?.runtimeType == e2?.runtimeType;
  }
  
  @override
  int hash(Object? e) {
    return e?.runtimeType.hashCode ?? null.hashCode;
  }
  
  @override
  bool isValidKey(Object? o) {
    return true;
  }
}

@internal
const configurableListEquality = ListEquality(RuntimeTypeEquality());