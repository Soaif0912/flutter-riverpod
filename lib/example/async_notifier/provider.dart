import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_statemanagement/example/async_notifier/repository.dart';
import 'package:riverpod_statemanagement/example/async_notifier/user_model.dart';

part 'provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build() async {
    return fetchUser();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchUser());
  }

  Future<void> fetchUserById(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchUser(id));
  }
}

/// Alias so the provider can be consumed as either `userProvider` or `userNotifierProvider`
final userNotifierProvider = userProvider;
