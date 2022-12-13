import 'package:flutter_scope/flutter_scope.dart' show States;
import 'todo.dart';
import 'todo_filter.dart';

typedef _TestTodo = bool Function(Todo todo);

_TestTodo _testTodo(TodoFilter filter) {
  switch (filter) {
    case TodoFilter.all: return (_) => true;
    case TodoFilter.completed: return (todo) => todo.isCompleted;
    case TodoFilter.uncompleted: return (todo) => !todo.isCompleted;
  } 
}

List<Todo> filterTodos(List<Todo> todos, TodoFilter filter) {
  final test = _testTodo(filter);
  return todos
    .where(test)
    .toList();
}

States<List<Todo>> filteredTodosStates({
  required States<List<Todo>> todosStates,
  required States<TodoFilter> filterStates,
}) => States.combine2(
  states1: todosStates,
  states2: filterStates,
  combiner: filterTodos,
);