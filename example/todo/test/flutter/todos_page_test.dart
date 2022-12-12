
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_scope/flutter_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/dart/filtered_todos.dart';
import 'package:todo/dart/todo.dart';
import 'package:todo/dart/todo_filter.dart';
import 'package:todo/dart/todo_filter_notifier.dart';
import 'package:todo/dart/todos_notifier.dart';
import 'package:todo/flutter/my_navigator.dart';
import 'package:todo/flutter/todos_page.dart';

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

class _MyMockNavigator implements MyNavigator {

  Completer<Todo?>? addedTodo;

  @override
  Future<Todo?> requestAddTodo(BuildContext context) {
    addedTodo = Completer();
    return addedTodo!.future;
  }
}

void main() {

  testWidgets('`TodosView` convert input `states` into widget tree', (tester) async {
    
    final todoFilter = Variable(TodoFilter.all);
    final todos = Variable(<Todo>[]);

    await tester.pumpWidget(
      MaterialApp(
        home: TodosView(
          todoFilterStates: todoFilter.asStates(),
          todosStates: todos.asStates(),
          onTodoFilterChanged: (_) {},
          onTodoCompleteChanged: (_) {},
          onTodoDismissed: (_) {},
          onAddTodoPressed: (_) {},
        ),
      ),
    );

    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('Todos is empty'), findsOneWidget);
    expect(find.byType(TodoTile), findsNothing);

    todoFilter.value = TodoFilter.completed;
    await tester.pump();
    expect(find.text('COMPLETED'), findsOneWidget);

    todos.value = [_uncompletedTodo1];
    await tester.pump();
    expect(find.text('Todos is empty'), findsNothing);  
    expect(find.byType(TodoTile), findsOneWidget);
    expect(tester.firstWidget<TodoTile>(find.byType(TodoTile)).todo, _uncompletedTodo1);

    todos.value = [_completedTodo1];
    await tester.pump();
    expect(find.text('Todos is empty'), findsNothing);  
    expect(find.byType(TodoTile), findsOneWidget);
    expect(tester.firstWidget<TodoTile>(find.byType(TodoTile)).todo, _completedTodo1);

    todoFilter.dispose();
    todos.dispose();
  });

  testWidgets('`TodosView` send output `events` back via callbacks', (tester) async {

    final todoFilter = Variable(TodoFilter.all);
    final todos = Variable([_uncompletedTodo1]);

    final invokes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: TodosView(
          todoFilterStates: todoFilter.asStates(),
          todosStates: todos.asStates(),
          onTodoFilterChanged: (filter) {
            invokes.add('onTodoFilterChanged(filter: $filter)');
          },
          onTodoCompleteChanged: (todoId) {
            invokes.add('onTodoCompleteChanged(todoId: $todoId)');
          },
          onTodoDismissed: (todoId) {
            invokes.add('onTodoDismissed(todo: $todoId)');
          },
          onAddTodoPressed: (context) {
            invokes.add('onAddTodoPressed(context: $context)');
          },
        ),
      )
    );
    expect(invokes, const []);

    await tester.tap(find.byType(PopupMenuButton<TodoFilter>));
    await tester.pumpAndSettle();
    expect(find.text('UNCOMPLETED'), findsOneWidget);
    await tester.tap(find.text('UNCOMPLETED'));
    await tester.pumpAndSettle();
    expect(invokes, [
      'onTodoFilterChanged(filter: TodoFilter.uncompleted)',
    ]);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(invokes, [
      'onTodoFilterChanged(filter: TodoFilter.uncompleted)',
      'onTodoCompleteChanged(todoId: 1)',
    ]);

    await tester.drag(find.byType(ListTile), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(invokes, [
      'onTodoFilterChanged(filter: TodoFilter.uncompleted)',
      'onTodoCompleteChanged(todoId: 1)',
      'onTodoDismissed(todo: 1)',
    ]);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(invokes, [
      'onTodoFilterChanged(filter: TodoFilter.uncompleted)',
      'onTodoCompleteChanged(todoId: 1)',
      'onTodoDismissed(todo: 1)',
      'onAddTodoPressed(context: TodosView)',
    ]);

    todoFilter.dispose();
    todos.dispose();
  });

  testWidgets('`TodosPage` common usage', (tester) async {

    final myNavigator = _MyMockNavigator();

    // test initial widget tree
    await tester.pumpWidget(
      MaterialApp(
        home: FlutterScope(
          configure: [
            Final<MyNavigator>(equal: (_) => myNavigator),
            FinalValueNotifier<TodosNotifier, TodosState>(
              equal: (_) => TodosNotifier(),
            ),
            FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
              equal: (_) => TodoFilterNotifier(),
            ),
            FinalStates<List<Todo>>(
              equal: (scope) => filteredTodos(
                todosStates: scope.get<States<TodosState>>()
                  .convert((state) => state.todos.values.toList()),
                filterStates: scope.get(),
              ),
            ),
          ],
          child: const TodosPage(),
        ),
      ),
    );

    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('Todos is empty'), findsOneWidget);
    expect(find.byType(TodoTile), findsNothing);

    // test request add todo
    await tester.tap(find.byType(FloatingActionButton));
    myNavigator.addedTodo!.complete(_uncompletedTodo1);
    await tester.pumpAndSettle();

    expect(find.text('Todos is empty'), findsNothing);
    expect(find.byType(TodoTile), findsOneWidget);
    expect(tester.firstWidget<TodoTile>(find.byType(TodoTile)).todo, _uncompletedTodo1);

    // test filter completed
    await tester.tap(find.byType(PopupMenuButton<TodoFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPLETED'));    
    await tester.pumpAndSettle();

    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('Todos is empty'), findsOneWidget);
    expect(find.byType(TodoTile), findsNothing);

    // test filter uncompleted
    await tester.tap(find.byType(PopupMenuButton<TodoFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UNCOMPLETED'));    
    await tester.pumpAndSettle();

    expect(find.text('Todos is empty'), findsNothing);
    expect(find.byType(TodoTile), findsOneWidget);
    expect(tester.firstWidget<TodoTile>(find.byType(TodoTile)).todo, _uncompletedTodo1);

    // test toggle completed, mark completed
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('Todos is empty'), findsOneWidget);
    expect(find.byType(TodoTile), findsNothing);

    // test filter completed
    await tester.tap(find.byType(PopupMenuButton<TodoFilter>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPLETED'));    
    await tester.pumpAndSettle();

    expect(find.text('Todos is empty'), findsNothing);
    expect(find.byType(TodoTile), findsOneWidget);
    expect(tester.firstWidget<TodoTile>(find.byType(TodoTile)).todo, _completedTodo1); 

    // test remove todo
    await tester.drag(find.byType(TodoTile), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Todos is empty'), findsOneWidget);
    expect(find.byType(TodoTile), findsNothing);

  });
}