
import 'package:flutter/material.dart';
import 'package:todo/flutter/add_todo_page.dart';

import '../dart/todo.dart';

class MyNavigator {

  const MyNavigator();

  Future<Todo?> requestAddTodo(BuildContext context) async {
    return await Navigator.push(context, MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    )) as Todo?;
  }
}
