import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  List<UserEntity> _topStudents = [];
  List<UserEntity> _leaderboard = [];
  bool _isLoading = false;

  HomeProvider(this._apiClient);

  List<UserEntity> get topStudents => _topStudents;
  List<UserEntity> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/user');
      if (response.statusCode == 200) {
        final List<dynamic> studentsJson = response.data['top_students'] ?? [];
        _topStudents = studentsJson.map<UserEntity>((json) {
          return UserEntity(
            id: json['id'] ?? 0,
            name: json['name'],
            email: '',
            score: json['score'] ?? 0,
            role: json['class'],
            className: json['class'] ?? 'General',
            progressPercentage: 0,
            rank: 0,
            wordsLearned: 0,
            totalWords: 0,
            exercisesDone: 0,
          );
        }).toList();
      }
    } catch (e) {
      // Ignored for now
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/leaderboard');
      final List list = response.data['leaderboard'] ?? [];
      _leaderboard = list.map<UserEntity>((json) => UserEntity(
        id: json['id'] ?? 0,
        name: json['name'],
        email: '',
        score: json['score'] ?? 0,
        role: json['class'],
        className: json['class'] ?? 'General',
        progressPercentage: 0,
        rank: 0,
        wordsLearned: 0,
        totalWords: 0,
        exercisesDone: 0,
      )).toList();
    } catch (e) {
      debugPrint("Error fetching leaderboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
