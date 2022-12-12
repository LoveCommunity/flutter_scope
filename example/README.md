# example

```
.
├── counter       // an application that records the count of button presses.
└── todo          // an todo application
```

## counter example preview

```dart
import 'package:flutter/material.dart';
import 'package:flutter_scope/flutter_scope.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Demo',
      home: CounterScope(
        child: const CounterView(
          title: 'Counter Page',
        ),
      ),
    );
  }
}

typedef CounterState = int;

// State manager that manages counter state
class Counter extends ValueNotifier<CounterState> {
  Counter(): super(0);

  void increment() {
    value += 1;
  }
}

class CounterScope extends FlutterScope {
  CounterScope({ 
    super.key,
    required super.child,
  }): super(
    configure: [
      // Expose a `counter` in current flutter scope from `final counter = Counter();` 
      FinalValueNotifier<Counter, CounterState>(equal: (scope) => Counter()),
    ],
  );
}

class CounterView extends StatelessWidget {
  const CounterView({ 
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            // Convert counter state to UI, as: UI = f(state)
            StatesBuilder<CounterState>(
              builder: (context, count) => Text(
                '$count',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Dispatch user interaction event to state manager
        onPressed: context.scope.get<Counter>().increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```