
import 'package:test/test.dart';
import 'package:todo/dart/todo_filter.dart';
import 'package:todo/dart/todo_filter_notifier.dart';

void main() {

  test('TodoFilterNotifier common usage', () {
    
    final notifier = TodoFilterNotifier();
    expect(notifier.value, TodoFilter.all);

    notifier.updateFilter(TodoFilter.uncompleted);
    expect(notifier.value, TodoFilter.uncompleted);

    notifier.updateFilter(TodoFilter.completed);
    expect(notifier.value, TodoFilter.completed);
  });
}