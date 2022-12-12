
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'todo.dart';

class AddTodoState {
  const AddTodoState({
    this.todoTitle = '',
    this.todoSubmitted,
  });

  final String todoTitle;
  final Todo? todoSubmitted;
  bool get isTodoTitleValid => todoTitle.trim().isNotEmpty;

  AddTodoState copyWith({
    String? todoTitle,
    Todo? todoSubmitted,
  }) => AddTodoState(
    todoTitle: todoTitle ?? this.todoTitle,
    todoSubmitted: todoSubmitted ?? this.todoSubmitted,
  );

  @override
  bool operator==(Object other) {
    return identical(this, other)
      || other is AddTodoState
        && todoTitle == other.todoTitle
        && todoSubmitted == other.todoSubmitted;
  }

  @override
  int get hashCode {
    return Object.hash(
      AddTodoState,
      todoTitle,
      todoSubmitted,
    );
  }

  @override
  String toString() {
    return 'AddTodoState(todoTitle: $todoTitle, todoSubmitted: $todoSubmitted)';
  }
}

class AddTodoNotifier extends ValueNotifier<AddTodoState> {

  AddTodoNotifier(): super(const AddTodoState());

  void onTodoTitleChanged(String title) {
    value = value.copyWith(
      todoTitle: title
    );
  }

  void onTodoSubmitted() {
    value = value.copyWith(
      todoSubmitted: Todo(
        id: const Uuid().v4(),
        creationDate: DateTime.now(),
        title: value.todoTitle,
        isCompleted: false,
      )
    );
  }
}