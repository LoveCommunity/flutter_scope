
class Todo {
  const Todo({
    required this.id,
    required this.creationDate,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final DateTime creationDate;
  final String title;
  final bool isCompleted;

  Todo copyWith({
    String? id,
    DateTime? creationDate,
    String? title,
    bool? isCompleted,
  }) => Todo(
    id: id ?? this.id,
    creationDate: creationDate ?? this.creationDate,
    isCompleted: isCompleted ?? this.isCompleted,
    title: title ?? this.title,
  );

  @override
  bool operator==(Object other) {
    return identical(this, other)
      || other is Todo
        && id == other.id
        && creationDate == other.creationDate
        && title == other.title
        && isCompleted == other.isCompleted;
  } 

  @override
  int get hashCode {
    return Object.hash(
      Todo,
      id,
      creationDate,
      title, 
      isCompleted,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, creationDate: $creationDate, title: $title, isCompleted: $isCompleted)';
  }
}
