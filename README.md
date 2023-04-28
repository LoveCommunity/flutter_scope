# flutter_scope

[![Build Status](https://github.com/LoveCommunity/flutter_scope/workflows/Tests/badge.svg)](https://github.com/LoveCommunity/flutter_scope/actions/workflows/tests.yaml)
[![Coverage Status](https://img.shields.io/codecov/c/github/LoveCommunity/flutter_scope/main.svg)](https://codecov.io/gh/LoveCommunity/flutter_scope) 
[![Pub](https://img.shields.io/pub/v/flutter_scope)](https://pub.dev/packages/flutter_scope)

A declarative dependency injection library which use dart syntax and flutter style

## Features

* Configuration is aligned with syntax with dart language
* Scope strategy is aligned with scoping of functions
* Can handle async setup
* Using `Observable\States` as notification system with composition in mind
* Using `StatesBuilder` to map a sequence of state to widget
* Using `StatesListener` to add a listener in flutter layer

## Table Of Content

- [flutter_scope](#flutter_scope)
  - [Features](#features)
  - [Table Of Content](#table-of-content)
  - [Packages](#packages)
  - [Quick Tour](#quick-tour)
    - [Usage of `FlutterScope(...)`](#usage-of-flutterscope)
    - [Usage of `name`](#usage-of-name)
    - [Usage of `FlutterScope.async(...)`](#usage-of-flutterscopeasync)
    - [Usage of child scope](#usage-of-child-scope)
    - [Usage of `InheritedScope`](#usage-of-inheritedscope)
    - [Usage of `FlutterScope`'s `parentScope` parameter](#usage-of-flutterscopes-parentscope-parameter)
    - [Usage of `States`](#usage-of-states)
      - [Usage of `States.combine`](#usage-of-statescombine)
      - [Usage of `states.convert`](#usage-of-statesconvert)
    - [Usage of `StatesBuilder(...)`](#usage-of-statesbuilder)
      - [Usage of `StatesBuilder` with `States.combine` operator](#usage-of-statesbuilder-with-statescombine-operator)
    - [Usage of `StatesListener(...)`](#usage-of-stateslistener)
      - [Usage of `StatesListener` with `states.convert` operator](#usage-of-stateslistener-with-statesconvert-operator)

- [dart_scope](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#dart_scope)
  - [Features](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#features)
  - [Table Of Content](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#table-of-content)
  - [Quick Tour](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#quick-tour)
    - [Usage of `Scope.root(...)`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#usage-of-scoperoot)
    - [Usage of `name`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#usage-of-name)
    - [`Scope.root(...)` async setup](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#scoperoot-async-setup)
    - [Usage of `scope.push(...)`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#usage-of-scopepush)
    - [Usage of `scope.has<T>(...)`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#usage-of-scopehast)
    - [Usage of `scope.getOrNull<T>(...)`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#usage-of-scopegetornullt)
    - [Usage of `scope.dispose()`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#usage-of-scopedispose)
    - [(Non)Lazily assignment](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#nonlazily-assignment)
  - [Advanced](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#advanced)
    - [Configurable](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#configurable)
    - [Inline `Configurable`](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#inline-configurable)
    - [Decompose configuration](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#decompose-configuration)
    - [Compose configurations](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#compose-configurations)

## Packages

- [dart_scope](https://pub.dev/packages/dart_scope) - a dart's declarative dependency injection library
- [flutter_scope](https://pub.dev/packages/flutter_scope) - a flutter's declarative dependency injection library

## Quick Tour

Let's explore with quick examples, assume we are developing a `todos` apps using [ValueNotifier]:

```dart
class TodosNotifier extends ValueNotifier<Map<String, Todo>> {
  TodosNotifier([super._value = const {}]);
  void addTodo(Todo todo) { ... }
  void toggleTodoCompleted(String todoId) { ... }
  void removeTodo(String todoId) { ... }
}

enum TodoFilter { all, completed, uncompleted }

class TodoFilterNotifier extends ValueNotifier<TodoFilter> {
  TodoFilterNotifier([super._value = TodoFilter.all]);
  void updateFilter(TodoFilter filter) { ... }
}
```

### Usage of `FlutterScope(...)`

Use `FlutterScope(...)` to create a scope with configurations:

```dart
FlutterScope(
  configure: [
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      name: 'todosNotifier',
      equal: (_) => TodosNotifier(),
    ),
    FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
      name: 'todoFilterNotifier',
      equal: (_) => TodoFilterNotifier(),
    ),
  ],
  child: Builder(
    builder: (context) {
      final myTodosNotifier = context.scope.get<TodosNotifier>(name: 'todosNotifier');
      final myTodoFilterNotifier = context.scope.get<TodoFilterNotifier>(name: 'todoFilterNotifier');
      return ...;
    }
  ),
);
```
A `FlutterScope` is created which expose singletons of `TodosNotifier` and `TodoFilterNotifier`. Later, these instances can be resolved by calling `context.scope.get<T>(...)`.

Above example simulates:

```dart
void flutterScope() { // `{` is the start of scope

  // create and exposed instances in current scope
  final TodosNotifier todosNotifier = TodosNotifier();
  final TodoFilterNotifier todoFilterNotifier = TodoFilterNotifier();

  // resolve instances in current scope
  final myTodosNotifier = todosNotifier;
  final myTodoFilterNotifier = todoFilterNotifier;

}                     // `}` is the end of scope
```

This simple pseudocode shown:
 - function scope that starts with `{`, ends with `}`
 - how to create and expose instances in current scope
 - how to resolve instances in current scope

### Usage of `name`

Use different names to create multiple instances:

```dart
FlutterScope(
  configure: [
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      name: 'todosNotifier1',
      equal: (_) => TodosNotifier(),
    ),
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      name: 'todosNotifier2',
      equal: (_) => TodosNotifier(),
    ),
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      name: 'todosNotifier3',
      equal: (_) => TodosNotifier(),
    ),
  ],
  child: Builder(
    builder: (context) {
      final myTodosNotifier1 = context.scope.get<TodosNotifier>(name: 'todosNotifier1');
      final myTodosNotifier2 = context.scope.get<TodosNotifier>(name: 'todosNotifier2');
      final myTodosNotifier3 = context.scope.get<TodosNotifier>(name: 'todosNotifier3');
      return ...;
    },
  ),
);
```

Which simulates:

```dart
void flutterScope() {
  final TodosNotifier todosNotifier1 = TodosNotifier();
  final TodosNotifier todosNotifier2 = TodosNotifier();
  final TodosNotifier todosNotifier3 = TodosNotifier();

  final myTodosNotifier1 = todosNotifier1;
  final myTodosNotifier2 = todosNotifier2;
  final myTodosNotifier3 = todosNotifier3;
}
```

Name can be private, so instance will only be resolved in current library (mostly current file):

```dart
final _privateName = Object();

class SomeWidget extends StatelessWidget {

  ...

  @override
  Widget build(BuildContext context) {
    return FlutterScope(
      configure: [
        FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
          name: _privateName, // use private name
          equal: (_) => TodosNotifier(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final myTodosNotifier = context.scope.get<TodosNotifier>(name: _privateName);
          return ...;
        },
      ),
    );
  }
}
```

Name can also be omitted, in this case `null` is used as name:

```dart
FlutterScope(
  configure: [
    // assigned without name
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      equal: (_) => TodosNotifier(),
    ),
  ],
  child: Builder(
    builder: (context) {
      // also resolved without name
      final myTodosNotifier = context.scope.get<TodosNotifier>();
      return ...;
    },
  ),
);
```

### Usage of `FlutterScope.async(...)`

Use `FlutterScope.async(...)` to create a scope with async configurations.

If there is async setup like resolving `SharedPreference`. We can follow this:

```dart
Future<Map<String, Todo>> resolveInitialTodosAsync() {
  await Future<void>.delayed(Duration(seconds: 1));
  return { ... };
}

...

FlutterScope.async( // use `async` constructor
  configure: [
    // using `AsyncFinal` to handle async setup
    AsyncFinal<Map<String, Todo>>(
      equal: (_) async {
        return await resolveInitialTodosAsync();
      },
    ),
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      equal: (scope) => TodosNotifier(
        scope.get<Map<String, Todo>>(),
      ),
    ),
  ],
  builder: (context, asyncScope) {
    switch (asyncScope.status) {
      case AsyncStatus.loading:
        return ...; // loading widget
      case AsyncStatus.error:
        return ...; // error widget
      case AsyncStatus.loaded:
        final scope = asyncScope.requireData;
        final myTodosNotifier = scope.get<TodosNotifier>();
        return ...; // success widget
    },
  },
);
```

Which simulates:

```dart
void flutterScope() async {
  final Map<String, Todo> initialTodos = await resolveInitialTodosAsync();
  final TodosNotifier todosNotifier = TodosNotifier(initialTodos);

  final myTodosNotifier = todosNotifier;
}
```

### Usage of child scope

Use `FlutterScope` to create a child scope which inherited getters from parent scope:

```dart
class AddTodoState { ... }
class AddTodoNotifier extends ValueNotifier<AddTodoState> { ... }

...

FlutterScope(
  configure: [
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      equal: (_) => TodosNotifier(),
    ),
    FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
      equal: (_) => TodoFilterNotifier(),
    ),
  ],
  child: FlutterScope( // creating a new scope in subtree of parent scope
    configure: [
      FinalValueNotifier<AddTodoNotifier, AddTodoState>(
        equal: (_) => AddTodoNotifier(),
      ),
    ],
    child: Builder(
      builder: (context) {
        final myTodoNotifier = context.scope.get<TodosNotifier>();
        final myTodoFilterNotifier = context.scope.get<TodoFilterNotifier>();
        final myAddTodoNotifier = context.scope.get<AddTodoNotifier>();
        return ...;
      },
    ),
  ),
);
```

Which simulates:

```dart
void flutterScope() {
  final TodosNotifier todosNotifier = TodosNotifier();
  final TodoFilterNotifier todoFilterNotifier = TodoFilterNotifier();

  void childFlutterScope() {
    final AddTodoNotifier addTodoNotifier = AddTodoNotifier();

    // resolve instances:
    //  `todosNotifier`       is inherited from parent scope
    //  `todoFilterNotifier`  is inherited from parent scope
    //  `addTodoNotifier`     is exposed in current scope
    final myTodosNotifier = todosNotifier;
    final myTodoFilterNotifier = todoFilterNotifier;
    final myAddTodoNotifier = addTodoNotifier;
  }
}
```

### Usage of `InheritedScope`

Use `InheritedScope` for making an exist scope available to subtree. This is useful when current route share scope with new route:

```dart
FlutterScope(
  configure: [
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      equal: (_) => TodosNotifier(),
    ),
    FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
      equal: (_) => TodoFilterNotifier(),
    ),
  ],
  child: Builder(
    builder: (context) {
      return Scaffold(
        ...
        floatActionButton: FloatActionButton(
          onPressed: () => _showAddTodoDialog(context),
          child: ...,
        ),
      ),
    },
  ),
);

...

void _showAddTodoDialog(BuildContext context) {
  showDialog( // show dialog will push a new route
    context: context,
    builder: (_) {
      return InheritedScope(  // use `InheritedScope` for
        scope: context.scope, // making exist scope available to subtree
        child: AlertDialog(
          ...,
          content: Builder(
            builder: (context) {
              // resolve instance in new route
              final myTodosNotifier = context.scope.get<TodosNotifier>();
              return ...;
            },
          ),
        ),
      );
    },
  );
}
```

Above example shown:
 - press `FloatActionButton` will push a new route
 - passing scope from current route to new route using `InheritedScope`
 - resolve `TodosNotifier` in new route


### Usage of `FlutterScope`'s `parentScope` parameter

Use `FlutterScope`'s `parentScope` parameter to create a new scope which is based on exist one, and has additional configurations. 

```diff
  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
-       return InheritedScope(  // use `InheritedScope` for
-         scope: context.scope, // making exist scope available to subtree
+       return FlutterScope(
+         parentScope: context.scope, // passing exist scope
+         configure: [                // with additional configurations
+           FinalValueNotifier<AddTodoNotifier, AddTodoState>(
+             equal: (_) => AddTodoNotifier(),
+           ),
+         ],
          child: AlertDialog(
            title: ...,
            content: Builder(
              builder: (context) {
                // resolve instance in new route
                final myTodosNotifier = context.scope.get<TodosNotifier>();
+               final myAddTodoNotifier = context.scope.get<AddTodoNotifier>();
                return ...;
              },
            ),
            actions: ...,
          ),
        );
      },
    );
  }
```

Which simulates:

```dart
void flutterScope() {
  final TodosNotifier todosNotifier = TodosNotifier();
  final TodoFilterNotifier todoFilterNotifier = TodoFilterNotifier();

  void childFlutterScope() {
    final AddTodoNotifier addTodoNotifier = AddTodoNotifier();

    final myTodosNotifier = todosNotifier;
    final myAddTodoNotifier = addTodoNotifier;
  }
}
```

We've covered the dependency injection part of `FlutterScope`. Now, let's explore `Observable/States` based notification system.

### Usage of `States`

`States` is a sequence of `state`.

It will replay current state synchronously, then emit following state asynchronously or synchronously.

Example in pure dart:

```dart
void flutterScope() async {
  final TodoFilterNotifier todosFilterNotifier = TodoFilterNotifier();
  final States<TodoFilter> todoFilterStates = todosFilterNotifierAsStates(todosFilterNotifier);

  late TodoFilter state;
  final observation = todoFilterStates.observe((todoFilter) { // start observe states
    print('simulate flutter set state');
    state = todoFilter;
    print('simulate map state to widget');
  }); 

  await Future<void>.delayed(const Duration(seconds: 3));
  print('simulate `navigator.pop(...)`');
  observation.dispose(); // stop observe

  ...// dispose `todosFilterNotifier`
}

// a function turns notifier to states
States<TodoFilter> todosFilterNotifierAsStates(TodoFilterNotifier notifier) { ... }
```

Above example shown:
 - `late TodoFilter state` is a plain state
 - `final States<TodoFilter> todoFilterStates` is a sequence of plain state. Sometimes `States` can be considered as plain state with a time dimension
 - use `todoFilterStates.observe(...)` to start observe states
 - use `observation.dispose()` to stop observe states
  
Note: `States` is similar to dart [Stream], but it is slightly different. `States` promise replay current state synchronously to observer, while dart [Stream] has its trade off, is designed not support this feature.

Since `States` has composition capability, let's introducing two common used operators.

#### Usage of `States.combine`

Use `States.combine` to combine multiple states into one `States`.

When an item is emitted by one of multiple States, combine the latest item emitted by each States via a specified function and emit combined item.

For example `filteredTodos` is computed by combining `todos` and `todoFilter`:

```dart
List<Todo> filterTodos(Map<String, Todo> todos, TodoFilter filter) {
  return todos.values
    .where((todo) {
      switch (filter) {
        case TodoFilter.all: return true;
        case TodoFilter.completed: return todo.isCompleted;
        case TodoFilter.uncompleted: return !todo.isCompleted;
      }
    })
    .toList();  
}

...

void flutterScope() async {
  ...

  final States<Map<String, Todo>> todosStates = ...;
  final States<TodoFilter> todoFilterStates = ...;

  final States<List<Todo>> filteredTodosStates = States.combine2(
    states1: todosStates,
    states2: todoFilterStates,
    combiner: filterTodos, // `filterTodos` is a pure function declared at top
  );

  late List<Todos> state;
  final observation = filteredTodosStates.observe((filteredTodos) {
    print('simulate flutter set state');
    state = filteredTodos;
    print('simulate map state to widget');
  }); 

  ...
}
```

Above example shown:
  - `filterTodos` is a pure function which compute plain `filteredTodos` by combining plain `todos` and `todoFilter`
  - `filteredTodosStates` is computed by combining `todosStates` and `todoFilterStates`

#### Usage of `states.convert`

Use `states.convert` to convert each item by applying a function and only emit result that changed.

For example `todosLength` is converted from `todos`:

```dart
void flutterScope() {
  final TodosNotifier todosNotifier = TodosNotifier();
  final States<Map<String, Todo>> todosStates = todosNotifierAsStates(todosNotifier);

  // `todosLength` is converted from `todos`
  final States<int> todosLengthStates = todosStates
    .convert((todos) => todos.length);

  final observation = todosLengthStates.observe((todosLength) {
    print('todos length changed to $todosLength');
  }); 

  ...
}
```

We've seen basic usage of `States`, let's see how to integrate with flutter.

### Usage of `StatesBuilder(...)`

Use `StatesBuilder(...)` to map a sequence of state to widget, as `UI = f(state).` 

```dart
FlutterScope(
  configure: [
    FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
      equal: (_) => TodoFilterNotifier(),
    ),
  ],
  child: StatesBuilder<TodoFilter>(
    builder: (context, todoFilter) {
      return ...; // map state to widget
    },
  ),
);
```

Which simulates:

```dart
void flutterScope() async {
  final TodoFilterNotifier todosFilterNotifier = TodoFilterNotifier();
  final States<TodoFilter> todoFilterStates = todosFilterNotifierAsStates(todosFilterNotifier);

  late TodoFilter state;
  final observation = todoFilterStates.observe((todoFilter) {
    print('simulate flutter set state');
    state = todoFilter;
    print('simulate map state to widget');
  }); 

  ...
}

...
```

`StatesBuilder` has composition capability, since it is based on `States`.

#### Usage of `StatesBuilder` with `States.combine` operator

Use `StatesBuilder` with `States.combine` operator to combine multiple states into one states, then map it to widget.

```dart
...

FlutterScope(
  configure: [
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      equal: (_) => TodosNotifier(),
    ),
    FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
      equal: (_) => TodoFilterNotifier(),
    ),
  ],
  child: Builder(
    builder: (context) {
      return StatesBuilder<List<Todo>>(
        states: States.combine2(
          states1: context.scope.getStates<Map<String, Todo>>(),
          states2: context.scope.getStates<TodoFilter>(),
          combiner: filterTodos,
        ),
        builder: (context, filteredTodos) {
          return ...; // map state to widget
        },
      );
    },
  ),
);
```

Which simulates:

```dart
...

void flutterScope() async {
  final TodosNotifier todosNotifier = TodosNotifier();
  final TodoFilterNotifier todosFilterNotifier = TodoFilterNotifier();
  final States<Map<String, Todo>> todosStates = todosNotifierAsStates(todosNotifier);
  final States<TodoFilter> todoFilterStates = todosFilterNotifierAsStates(todosFilterNotifier);

  final States<List<Todo>> filteredTodosStates = States.combine2(
    states1: todosStates,
    states2: todoFilterStates,
    combiner: filterTodos, 
  );

  late List<Todos> state;
  final observation = filteredTodosStates.observe((filteredTodos) {
    print('simulate flutter set state');
    state = filteredTodos;
    print('simulate map state to widget');
  }); 

  ...
}
```

### Usage of `StatesListener(...)`

Use `StatesListener(...)` to add a listener in flutter layer.

```dart
FlutterScope(
  configure: [
    FinalValueNotifier<TodoFilterNotifier, TodoFilter>(
      equal: (_) => TodoFilterNotifier(),
    ),
  ],
  child: StatesListener<TodoFilter>(
    onData: (context, todoFilter) {
      ScaffoldMessenger.of(context)
        .showSnackbar(SnackBar(
          content: Text('todo filter changed to $todoFilter'),
        ));
    },
    child: ...,
  ),
);
```

Which simulates:

```dart
void flutterScope() async {
  final TodoFilterNotifier todosFilterNotifier = TodoFilterNotifier();
  final States<TodoFilter> todoFilterStates = todosFilterNotifierAsStates(todosFilterNotifier);

  final observation = todoFilterStates.observe((todoFilter) {
    print('todo filter changed to $todoFilter');
  }); 

  ...
}

...
```

`StatesListener` also has composition capability, since it is based on `States`.

#### Usage of `StatesListener` with `states.convert` operator

Use `StatesListener` with `states.convert` operator to convert states to another states, then add a listener to the states.

```dart
FlutterScope(
  configure: [
    FinalValueNotifier<TodosNotifier, Map<String, Todo>>(
      equal: (_) => TodosNotifier(),
    ),
  ],
  child: Builder(
    builder: (context) {
      return StatesListener<int>(
        states: context.scope.getStates<Map<String, Todo>>()
          .convert((todos) => todos.length),
        onData: (context, todosLength) {
          ScaffoldMessenger.of(context)
            .showSnackbar(SnackBar(
              content: Text('todos length changed to $todosLength'),
            ));
        },
        child: ...,
      );
    },
  ),
);
```

Which simulates:

```dart
void flutterScope() {
  final TodosNotifier todosNotifier = TodosNotifier();
  final States<Map<String, Todo>> todosStates = todosNotifierAsStates(todosNotifier);

  // `todosLength` is converted from `todos`
  final States<int> todosLengthStates = todosStates
    .convert((todos) => todos.length);

  final observation = todosLengthStates.observe((todosLength) {
    print('todos length changed to $todosLength');
  });

  ...
}

...
```

[**Next Page - dart_scope**](https://pub.dev/packages/dart_scope/versions/0.1.0-beta.2#dart_scope)

[ValueNotifier]:https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html
[Stream]:https://dart.dev/tutorials/language/streams