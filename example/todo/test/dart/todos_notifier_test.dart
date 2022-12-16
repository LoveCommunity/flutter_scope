import 'package:test/test.dart';
import 'package:todo/dart/item_changed.dart';
import 'package:todo/dart/todo.dart';
import 'package:todo/dart/todos_notifier.dart';

final _uncompletedTodo1 = Todo(
  id: '1',
  creationDate: DateTime(2001),
  title: 'todo1',
  isCompleted: false
);

final _completedTodo1 = Todo(
  id: '1',
  creationDate: DateTime(2001),
  title: 'todo1',
  isCompleted: true,
);

final _uncompletedTodo2 = Todo(
  id: '2',
  creationDate: DateTime(2002),
  title: 'todo2',
  isCompleted: false
);

final _completedTodo2 = Todo(
  id: '2',
  creationDate: DateTime(2002),
  title: 'todo2',
  isCompleted: true,
);

void main() {

  test('`TodosNotifier` updates value', () {

    final notifier = TodosNotifier();
    expect(notifier.value, TodosState.empty);

    notifier.addTodo(_uncompletedTodo1);
    expect(notifier.value, TodosState(
      todos: {
        '1': _uncompletedTodo1,
      },
      changes: TodoChanges(
        inserts: {
          '1': ItemInserted(_uncompletedTodo1),
        },
        updates: const {},
        removes: const {},
      )
    ));

    notifier.addTodo(_uncompletedTodo2);
    expect(notifier.value, TodosState(
      todos: {
        '1': _uncompletedTodo1,
        '2': _uncompletedTodo2,
      },
      changes: TodoChanges(
        inserts: {
          '2': ItemInserted(_uncompletedTodo2),
        },
        updates: const {},
        removes: const {},
      )
    ));

    notifier.toggleTodoCompleted('1');
    expect(notifier.value, TodosState(
      todos: {
        '1': _completedTodo1,
        '2': _uncompletedTodo2,
      },
      changes: TodoChanges(
        inserts: const {},
        updates: {
          '1': ItemUpdated(
            oldItem: _uncompletedTodo1, 
            item: _completedTodo1
          ),
        },
        removes: const {},
      ),
    ));

    notifier.toggleTodoCompleted('2');
    expect(notifier.value, TodosState(
      todos: {
        '1': _completedTodo1,
        '2': _completedTodo2,
      },
      changes: TodoChanges(
        inserts: const {},
        updates: {
          '2': ItemUpdated(
            oldItem: _uncompletedTodo2, 
            item: _completedTodo2
          ),
        },
        removes: const {},
      ),
    ));

    notifier.removeTodo('2');
    expect(notifier.value, TodosState(
      todos: {
        '1': _completedTodo1,
      },
      changes: TodoChanges(
        inserts: const {},
        updates: const {},
        removes: {
          '2': ItemRemoved(_completedTodo2),
        },
      ),
    ));

    notifier.removeTodo('1');
    expect(notifier.value, TodosState(
      todos: const {},
      changes: TodoChanges(
        inserts: const {},
        updates: const {},
        removes: {
          '1': ItemRemoved(_completedTodo1),
        },
      ),
    ));

  });
}