import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final ApiClient _apiClient;

  UserEntity? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;
  List<dynamic> _achievements = [];
  List<dynamic> _newlyUnlocked = [];

  AuthProvider(this._authRepository, this._tokenStorage, this._apiClient);

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  List<dynamic> get achievements => _achievements;
  List<dynamic> get newlyUnlocked => _newlyUnlocked;

  Future<void> checkStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final token = await _tokenStorage.getToken();
    if (token != null) {
      _apiClient.setToken(token);
      final user = await _authRepository.fetchUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        await _tokenStorage.clearToken();
        _apiClient.clearToken();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final (user, token) = await _authRepository.login(email, password);
      _currentUser = user;
      await _tokenStorage.saveToken(token);
      _apiClient.setToken(token);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  void updateUser(UserEntity user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> fetchUser() async {
    try {
      final response = await _apiClient.get('/user');
      final userData = response.data['user'];
      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
        _achievements = response.data['achievements'] ?? [];
        _newlyUnlocked = response.data['newly_unlocked'] ?? [];
        notifyListeners();
      }
    } catch (e) {
       debugPrint("Error fetching user: $e");
    }
  }

  void clearNewlyUnlocked() {
    _newlyUnlocked = [];
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _authRepository.logout();
    await _tokenStorage.clearToken();
    _apiClient.clearToken();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
