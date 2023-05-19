import 'package:flutter_scope/flutter_scope.dart';
import 'package:test/test.dart';
import 'package:todo/dart/filter_todos_states.dart';
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

final _todos = <String, Todo>{
  '1': _uncompletedTodo,
  '2': _completedTodo,
};

void main() {

  test('filterTodos using TodoFilter.all', () {
    final todos = filterTodos(_todos, TodoFilter.all);
    expect(todos, [
      _uncompletedTodo,
      _completedTodo,
    ]);
  });

  test('filterTodos using TodoFilter.completed', () {
    final todos = filterTodos(_todos, TodoFilter.completed);
    expect(todos, [
      _completedTodo
    ]);
  });

  test('filterTodos using TodoFilter.uncompleted', () {
    final todos = filterTodos(_todos, TodoFilter.uncompleted);
    expect(todos, [
      _uncompletedTodo
    ]);
  });

  test('filterTodosStates common usage', () {
    
    final List<List<Todo>> recorded = [];

    final todos = Variable(_todos);
    final filter = Variable(TodoFilter.all);

    final states = filterTodosStates(
      todosStates: todos.asStates(),
      filterStates: filter.asStates(),
    );

    final observation = states.observe(recorded.add);
    expect(recorded, [
      [_uncompletedTodo, _completedTodo],
    ]);

    filter.value = TodoFilter.completed;
    expect(recorded, [
      [_uncompletedTodo, _completedTodo],
      [_completedTodo],
    ]);

    todos.value = {};
    expect(recorded, [
      [_uncompletedTodo, _completedTodo],
      [_completedTodo],
      [],
    ]);

    observation.dispose();
    todos.dispose();
    filter.dispose();
  });
}