import 'package:flutter/material.dart';
import 'package:flutter_scope/flutter_scope.dart';
import '../dart/todos_notifier.dart';
import '../dart/todo.dart';
import '../dart/todo_filter_notifier.dart';
import '../dart/todo_filter.dart';
import '../dart/filter_todos_states.dart';
import 'my_navigator.dart';
import 'todos_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      child: const MyMaterialApp(),
    );
  }
}

class AppScope extends FlutterScope {
  AppScope({
    super.key,
    required super.child,
  }): super(
    configure: [
      Final<MyNavigator>(equal: (_) => const MyNavigator()),
      FinalValueNotifier<TodosNotifier, TodosState>(
        equal: (_) => TodosNotifier(),
      ),
      FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
        equal: (_) => TodoFilterNotifier(),
      ),
      FinalStates<List<Todo>>(
        equal: (scope) => filterTodosStates(
          todosStates: scope.getStates<TodosState>()
            .convert((state) => state.todos),
          filterStates: scope.get(),
        ),
      ),
    ],
  );
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Demo',
      builder: (context, child) => TodoChangesListener(
        child: child!,
      ),
      home: const TodosPage(),
    );
  }
}

class TodoChangesListener extends StatelessWidget {
  const TodoChangesListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StatesListener(
      states: context.scope.getStates<TodosState>()
        .convert((state) => state.changes),
      onData: (context, changes) {
        final text = [
          if (changes.inserts.isNotEmpty) '${changes.inserts.length} todo(s) inserted',
          if (changes.updates.isNotEmpty) '${changes.updates.length} todo(s) updated',
          if (changes.removes.isNotEmpty) '${changes.removes.length} todo(s) removed',
        ].join(', ');
        if (text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(text),
          ));
        }
      },
      child: child,
    );
  }
}

