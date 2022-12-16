import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'item_changed.dart';
import 'todo.dart';

typedef TodoChanges = ItemChanges<String, Todo>;

class TodosState {
  static const empty = TodosState(
    todos: {},
    changes: TodoChanges(),
  );
  const TodosState({
    required this.todos,
    required this.changes,
  });
  final Map<String, Todo> todos;
  final TodoChanges changes;

  @override
  bool operator==(Object other) {
    const mapEquality = MapEquality();
    return identical(this, other)
      || other is TodosState 
        && mapEquality.equals(todos, other.todos)
        && changes == other.changes;
  }

  @override
  int get hashCode {
    const mapEquality = MapEquality();
    return Object.hash(
      TodosState,
      mapEquality.hash(todos),
      changes,
    );
  }

  @override
  String toString() {
    return 'TodosState(todos: $todos, changes: $changes)';
  }
}

class TodosNotifier extends ValueNotifier<TodosState> {
  TodosNotifier(): super(TodosState.empty);

  void addTodo(Todo todo) {
    value = TodosState(
      todos: {
        ...value.todos,
        todo.id: todo,
      },
      changes: ItemChanges(
        inserts: {
          todo.id: ItemInserted(todo),
        },
      ),
    );
  }

  void toggleTodoCompleted(String todoId) {
    final todos = value.todos.map(
      (key, todo) => MapEntry(
        key,
        key == todoId
          ? todo.copyWith(isCompleted: !todo.isCompleted)
          : todo,
      )
    );
    final updated = ItemUpdated<Todo>(
      oldItem: value.todos[todoId]!,
      item: todos[todoId]!
    );
    value = TodosState(
      todos: todos,
      changes: ItemChanges(
        updates: {
          todoId: updated
        },
      ),
    );
  }

  void removeTodo(String todoId) {
    value = TodosState(
      todos: Map.fromEntries(
        value.todos.entries
          .where((entry) => entry.key != todoId)
      ),
      changes: ItemChanges(
        removes: {
          todoId: ItemRemoved(value.todos[todoId]!),
        },  
      ),
    );
  }
}