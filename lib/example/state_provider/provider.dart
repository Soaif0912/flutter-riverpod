import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final CounterProvider = StateProvider<int>((ref) {
  return 0;
});

void increment(WidgetRef ref) {
  ref.read(CounterProvider.notifier).state++;
}
