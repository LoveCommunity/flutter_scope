import 'package:flutter_scope/flutter_scope.dart';
import 'package:test/test.dart';
import 'package:todo/dart/filtered_todos_states.dart';
import 'package:todo/dart/todo.dart';
import 'package:todo/dart/todo_filter.dart';


final _uncompletedTodo = Todo(
  id: '1',
  creationDate: DateTime(2001),
  title: 'uncompletedTodo',
  isCompleted: false
);

final _completedTodo = Todo(
  id: '2',
  creationDate: DateTime(2002),
  title: 'completedTodo',
  isCompleted: true,
);

final List<Todo> _todos = [
  _uncompletedTodo,
  _completedTodo,
];

void main() {

  test('`filteredTodos` using `TodoFilter.all`', () {
    final todos = filteredTodos(_todos, TodoFilter.all);
    expect(todos, [
      _uncompletedTodo,
      _completedTodo,
    ]);
  });

  test('`filteredTodos` using `TodoFilter.completed`', () {
    final todos = filteredTodos(_todos, TodoFilter.completed);
    expect(todos, [
      _completedTodo
    ]);
  });

  test('`filteredTodos` using `TodoFilter.uncompleted`', () {
    final todos = filteredTodos(_todos, TodoFilter.uncompleted);
    expect(todos, [
      _uncompletedTodo
    ]);
  });

  test('`filteredTodosStates` common usage', () {
    
    final List<List<Todo>> recorded = [];

    final todos = Variable(_todos);
    final filter = Variable(TodoFilter.all);

    final states = filteredTodosStates(
      todosStates: todos.asStates(),
      filterStates: filter.asStates(),
    );

    final observation = states.observe(recorded.add);
    expect(recorded, [
      _todos
    ]);

    filter.value = TodoFilter.completed;
    expect(recorded, [
      _todos,
      [_completedTodo],
    ]);

    todos.value = [];
    expect(recorded, [
      _todos,
      [_completedTodo],
      [],
    ]);

    observation.dispose();
    todos.dispose();
    filter.dispose();
  });
}