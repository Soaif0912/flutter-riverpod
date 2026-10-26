import 'package:riverpod_statemanagement/core/exception/exception.dart';
import 'package:riverpod_statemanagement/core/service/http_service.dart';
import 'package:riverpod_statemanagement/example/async_notifier/user_model.dart';

class UserRepository {
  final HttpService _httpService;

  UserRepository({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  Future<User> fetchUser([int id = 1]) async {
    final url = Uri.parse('https://dummyjson.com/users/$id');

    final data = await _httpService.get(url);

    if (data is Map<String, dynamic>) {
      return User.fromJson(data);
    }
    throw AppException('Invalid user data received from server');
  }
}

final userRepository = UserRepository();

Future<User> fetchUser([int id = 1]) => userRepository.fetchUser(id);
