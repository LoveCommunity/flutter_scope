
import 'package:flutter/material.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:intl/intl.dart';
import 'package:todo/flutter/shared.dart';

import '../dart/todo.dart';
import '../dart/todo_filter.dart';
import '../dart/todo_filter_notifier.dart';
import '../dart/todos_notifier.dart';
import 'my_navigator.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  static void _requestAddTodo(BuildContext context) async {
    final myNavigator = context.scope.get<MyNavigator>();
    final todosNotifier = context.scope.get<TodosNotifier>();
    final todo = await myNavigator.requestAddTodo(context); 
    if (todo != null) {
      todosNotifier.addTodo(todo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoFilterNotifier = context.scope.get<TodoFilterNotifier>();
    final todosNotifier = context.scope.get<TodosNotifier>();
    return TodosView(
      todoFilterStates: context.scope.get(),
      todosStates: context.scope.get(),
      onTodoFilterChanged: todoFilterNotifier.updateFilter,
      onTodoCompleteChanged: todosNotifier.toggleTodoCompleted,
      onTodoDismissed: todosNotifier.removeTodo,
      onAddTodoPressed: _requestAddTodo,
    );
  }
}

class TodosView extends StatelessWidget {
  const TodosView({
    super.key,
    required this.todoFilterStates,
    required this.todosStates,
    required this.onTodoFilterChanged,
    required this.onTodoCompleteChanged,
    required this.onTodoDismissed,
    required this.onAddTodoPressed,
  });

  final States<TodoFilter> todoFilterStates;
  final States<List<Todo>> todosStates;
  final ValueChanged<TodoFilter> onTodoFilterChanged;
  final ValueChanged<String> onTodoCompleteChanged;
  final ValueCallback<String> onTodoDismissed;
  final ValueCallback<BuildContext> onAddTodoPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        actions: [
          StatesBuilder(
            states: todoFilterStates,
            builder: (context, filter, _) {
              return TodoFilterButton(
                filter: filter,
                onSelected: onTodoFilterChanged,
              );
            }
          )
        ],
      ),
      body: StatesBuilder(
        states: todosStates,
        builder: (context, todos, _) => Stack(
          fit: StackFit.expand,
          children: [
            if (todos.isEmpty) Center(
              child: Text(
                'Todos is empty',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoTile(
                  todo: todo,
                  onCompletedChanged: (_) => onTodoCompleteChanged(todo.id),
                  onDismissed: () => onTodoDismissed(todo.id),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onAddTodoPressed(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    this.onCompletedChanged,
    this.onDismissed,
  });

  final Todo todo;
  final ValueChanged<bool?>? onCompletedChanged;
  final VoidCallback? onDismissed;

  Widget _maybeDismissible({
    required Widget child
  }) => onDismissed != null
    ? Dismissible(
        key: ValueKey(todo.id),
        onDismissed: (_) => onDismissed!(),
        child: child,
      )
    : child;

  static final _dateFormat = DateFormat.yMMMMd();

  @override
  Widget build(BuildContext context) {
    return _maybeDismissible(
      child: ListTile(
        key: ValueKey(todo.id),
        title: Text(todo.title),
        subtitle: Text('Created At ${_dateFormat.format(todo.creationDate)}'),
        trailing: Checkbox(
          onChanged: onCompletedChanged,
          value: todo.isCompleted,
        ),
      ),
    );
  }
}

class TodoFilterButton extends StatelessWidget {
  const TodoFilterButton({
    super.key,
    required this.filter,
    this.onSelected,
  });

  final TodoFilter filter;
  final PopupMenuItemSelected<TodoFilter>? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TodoFilter>(
      initialValue: filter,
      onSelected: onSelected,
      itemBuilder: (context) => TodoFilter.values.map(
        (filter) => PopupMenuItem<TodoFilter>(
          value: filter,
          child: Text(_filterDescription(filter)),
        ),
      ).toList(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(_filterDescription(filter)),
            const Icon(Icons.filter_alt),
          ],
        ),
      ),
    );
  }
}

String _filterDescription(TodoFilter filter) {
  return '$filter'.split('.').last.toUpperCase();
}