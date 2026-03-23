import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<(UserEntity user, String token)> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/mobile/login', data: {
        'email': email,
        'password': password,
        'device_name': 'android_emulator'
      });

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        final token = response.data['token'];
        return (user as UserEntity, token as String);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error. Please try again.');
    } catch (e) {
      throw Exception('Something went wrong. Please check your credentials.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/mobile/logout');
    } catch (e) {
      // Ignore if logout failed, we'll clear token in local storage anyway
    }
  }

  @override
  Future<UserEntity?> fetchUser() async {
    try {
      final response = await _apiClient.dio.get('/user');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']) as UserEntity;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
