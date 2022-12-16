
import 'package:test/test.dart';
import 'package:todo/dart/add_todo_notifier.dart';

void main() {
  test('`addTodoNotifier.onTodoTitleChanged` value updates', () {
    final notifier = AddTodoNotifier();
    expect(notifier.value, const AddTodoState());
    notifier.onTodoTitleChanged('todo title');
    expect(notifier.value, const AddTodoState(
      todoTitle: 'todo title',
      todoSubmitted: null
    ));
    notifier.onTodoSubmitted();
    final todoSubmitted = notifier.value.todoSubmitted;
    expect(todoSubmitted, isNotNull);
    expect(todoSubmitted?.title, 'todo title');
    expect(todoSubmitted?.isCompleted, false);
  });
}