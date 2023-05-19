
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/dart/todo.dart';
import 'package:todo/flutter/add_todo_page.dart';
import 'package:todo/flutter/my_navigator.dart';

void main() {

  testWidgets('AddTodoPage common usage', (tester) async {

    Todo? addedTodo;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                addedTodo = await const MyNavigator().requestAddTodo(context);
              },
              child: const Text('push')
            ),
          ),
        ),
      ),
    );
    expect(
      find.byType(AddTodoPage), 
      findsNothing
    );

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    expect(
      find.byType(AddTodoPage),
      findsOneWidget,
    );

    expect(find.text(''), findsOneWidget);
    expect(
      tester.firstWidget<FloatingActionButton>(find.byType(FloatingActionButton)).backgroundColor,
      Colors.grey,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoPage), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'todo1');
    await tester.pump();
    expect(
      tester.firstWidget<FloatingActionButton>(find.byType(FloatingActionButton)).backgroundColor,
      isNot(Colors.grey),
    );

    expect(addedTodo, isNull);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoPage), findsNothing);
    expect(addedTodo?.title, 'todo1');

  });
}