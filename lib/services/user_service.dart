import 'dart:io';
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

  /// Загрузка аватарки пользователя (POST /users/{id}/avatar)
  Future<APIUserResponse> uploadAvatar(int userId, File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });
    final response = await _dio.post(
      '/users/$userId/avatar',
      data: formData,
    );
    return APIUserResponse.fromJson(response.data);
  }

  /// Удаление аватарки пользователя (DELETE /users/{id}/avatar)
  Future<APIUserResponse> deleteAvatar(int userId) async {
    final response = await _dio.delete('/users/$userId/avatar');
    return APIUserResponse.fromJson(response.data);
  }

  /// Регистрация нового пользователя (POST /auth/register)
  /// Поддерживает как fullName, так и раздельные firstName/lastName/middleName
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    String? fullName,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phoneNumber,
    String? position,
    String? notes,
    String? role,
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
    };
    if (fullName != null && fullName.isNotEmpty) body['full_name'] = fullName;
    if (firstName != null && firstName.isNotEmpty) body['first_name'] = firstName;
    if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName;
    if (middleName != null && middleName.isNotEmpty) body['middle_name'] = middleName;
    if (phoneNumber != null && phoneNumber.isNotEmpty) body['phone_number'] = phoneNumber;
    if (position != null && position.isNotEmpty) body['position'] = position;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    if (role != null && role.isNotEmpty) body['role'] = role;

    final response = await _dio.post('/auth/register', data: body);
    return response.data as Map<String, dynamic>;
  }

  /// Обновление пользователя администратором (PUT /users/{id})
  Future<APIUserResponse> updateUserByAdmin({
    required int userId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? middleName,
    String? phoneNumber,
    String? position,
    String? notes,
    String? role,
    bool? isActive,
    bool? isBlocked,
    bool? canEditOffline,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (middleName != null) body['middle_name'] = middleName;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    if (position != null) body['position'] = position;
    if (notes != null) body['notes'] = notes;
    if (role != null) body['role'] = role;
    if (isActive != null) body['is_active'] = isActive;
    if (isBlocked != null) body['is_blocked'] = isBlocked;
    if (canEditOffline != null) body['can_edit_offline'] = canEditOffline;

    final response = await _dio.put('/users/$userId', data: body);
    return APIUserResponse.fromJson(response.data);
  }

  /// Изменение пароля пользователя администратором (POST /users/{id}/change-password)
  Future<void> changeUserPasswordByAdmin({
    required int userId,
    required String newPassword,
  }) async {
    await _dio.post('/users/$userId/change-password', data: {
      'new_password': newPassword,
    });
  }

  /// Деактивация пользователя (POST /users/{id}/deactivate)
  Future<void> deactivateUser(int userId) async {
    await _dio.post('/users/$userId/deactivate');
  }

  /// Активация пользователя (POST /users/{id}/activate)
  Future<void> activateUser(int userId) async {
    await _dio.post('/users/$userId/activate');
  }

  /// Блокировка пользователя (POST /users/{id}/block)
  Future<void> blockUser(int userId) async {
    await _dio.post('/users/$userId/block');
  }

  /// Разблокировка пользователя (POST /users/{id}/unblock)
  Future<void> unblockUser(int userId) async {
    await _dio.post('/users/$userId/unblock');
  }

  /// Удаление пользователя (DELETE /users/{id})
  Future<void> deleteUser(int userId) async {
    await _dio.delete('/users/$userId');
  }
}

// Provider to hold and cache the list of users
final usersProvider = FutureProvider<List<APIUserResponse>>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getAllUsers();
});

final usersMapProvider = FutureProvider<Map<int, APIUserResponse>>((ref) async {
  final usersList = await ref.watch(usersProvider.future);
  return {for (var user in usersList) user.id: user};
});

