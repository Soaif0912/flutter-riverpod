import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_statemanagement/example/state_provider/provider.dart';

class StateProviderExamplePage extends ConsumerWidget {
  const StateProviderExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('rebuild');
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Consumer(
              builder: (context, ref, child) {
                final counter = ref.watch(CounterProvider);
                print('rebuild inside consumer');
                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          increment(ref);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
