
import 'package:flutter/material.dart';
import 'package:flutter_scope/flutter_scope.dart';

import '../dart/add_todo_notifier.dart';

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AddTodoScope( 
      child: const AddTodoView(),
    );
  }
}

class AddTodoScope extends FlutterScope {
  AddTodoScope({ 
    super.key,
    required super.child,
  }): super(
    configure: [
      FinalValueNotifier<AddTodoNotifier, AddTodoState>(
        equal: (scope) => AddTodoNotifier(),
      ),
    ]
  );
}

class AddTodoView extends StatelessWidget {
  const AddTodoView({ super.key });

  @override
  Widget build(BuildContext context) {
    final addTodoNotifier = context.scope.get<AddTodoNotifier>();
    final addTodoStates = context.scope.getStates<AddTodoState>();
    return StatesListener(
      states: addTodoStates
        .convert((state) => state.todoSubmitted),
      onData: (context, todoSubmitted) {
        Navigator.pop(context, todoSubmitted);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Todo'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: addTodoNotifier.onTodoTitleChanged,
            ),
          ),
        ),
        floatingActionButton: StatesBuilder(
          states: addTodoStates
            .convert((state) => state.isTodoTitleValid),
          builder: (context, isTodoTitleValid, _)  => FloatingActionButton(
            onPressed: isTodoTitleValid 
              ? addTodoNotifier.onTodoSubmitted 
              : null,
            backgroundColor: isTodoTitleValid ? null : Colors.grey,
            child: const Icon(Icons.save),
          )
        ),
      ),
    );
  }
}
