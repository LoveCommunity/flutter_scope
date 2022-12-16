
import 'package:collection/collection.dart';

abstract class ItemChanged<T> {}
class ItemInserted<T> implements ItemChanged<T> {
  const ItemInserted(this.item);
  final T item;

  @override
  bool operator==(Object other) {
    return identical(this, other)
      || other is ItemInserted<T>
        && item == other.item;
  }

  @override
  int get hashCode {
    return Object.hash(
      ItemInserted<T>,
      item,
    );
  }

  @override
  String toString() {
    return 'ItemInserted<$T>(item: $item)';
  }
}
class ItemUpdated<T> implements ItemChanged<T> {
  const ItemUpdated({
    required this.oldItem,
    required this.item,
  });
  final T oldItem;
  final T item;

  @override
  bool operator==(Object other) {
    return identical(this, other)
      || other is ItemUpdated<T>
        && oldItem == other.oldItem
        && item == other.item;
  }

  @override
  int get hashCode {
    return Object.hash(
      ItemUpdated<T>,
      oldItem,
      item,
    );
  }

  @override
  String toString() {
    return 'ItemUpdated<$T>(oldItem: $oldItem, item: $item)';
  }
}
class ItemRemoved<T> implements ItemChanged<T> {
  const ItemRemoved(this.item);
  final T item;

  @override
  bool operator==(Object other) {
    return identical(this, other)
      || other is ItemRemoved<T>
        && item == other.item;
  }

  @override
  int get hashCode {
    return Object.hash(
      ItemRemoved<T>,
      item,
    );
  }

  @override
  String toString() {
    return 'ItemRemoved<$T>(item: $item)';
  }
}

class ItemChanges<K, T> {
  const ItemChanges({
    this.inserts = const {},
    this.updates = const {},
    this.removes = const {},
  });
  final Map<K, ItemInserted<T>> inserts;
  final Map<K, ItemUpdated<T>> updates;
  final Map<K, ItemRemoved<T>> removes;

  @override
  bool operator==(Object other) {
    const mapEquality = MapEquality();
    return identical(this, other)
      || other is ItemChanges<K, T>
        && mapEquality.equals(inserts, other.inserts)
        && mapEquality.equals(updates, other.updates)
        && mapEquality.equals(removes, other.removes);

  }

  @override
  int get hashCode {
    const mapEquality = MapEquality();
    return Object.hash(
      ItemChanges<K, T>,
      mapEquality.hash(inserts),
      mapEquality.hash(updates),
      mapEquality.hash(removes),
    );
  }

  @override
  String toString() {
    return 'ItemChanges<$K, $T>(inserts: $inserts, updates: $updates, removes: $removes)';
  }
}
