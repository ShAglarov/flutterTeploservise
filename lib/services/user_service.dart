import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_models.dart';
import 'base_api_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio);
});

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<List<APIUserResponse>> getAllUsers() async {
    final response = await _dio.get('/users/');
    final users = (response.data as List)
        .map((e) => APIUserResponse.fromJson(e))
        .toList();
    return users;
  }
}

// Provider to hold and cache the list of users
final usersProvider = FutureProvider<List<APIUserResponse>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getAllUsers();
});
