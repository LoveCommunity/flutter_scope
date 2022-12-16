
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'todo_filter.dart';

class TodoFilterNotifier extends ValueNotifier<TodoFilter> {
  TodoFilterNotifier(): super(TodoFilter.all);

  void updateFilter(TodoFilter filter) {
    value = filter;
  }
}