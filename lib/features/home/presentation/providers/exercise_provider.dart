import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class ExerciseStats {
  final int totalExercises;
  final int totalPoints;
  final int completedCount;
  final int earnedPoints;

  ExerciseStats({
    required this.totalExercises,
    required this.totalPoints,
    required this.completedCount,
    required this.earnedPoints,
  });

  factory ExerciseStats.fromJson(Map<String, dynamic> json) {
    return ExerciseStats(
      totalExercises: json['total_exercises'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      earnedPoints: json['earned_points'] ?? 0,
    );
  }
}

class OverallStats {
  final int totalCompleted;
  final int totalExercises;
  final int totalPointsEarned;

  OverallStats({
    required this.totalCompleted,
    required this.totalExercises,
    required this.totalPointsEarned,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalCompleted: json['total_completed'] ?? 0,
      totalExercises: json['total_exercises'] ?? 0,
      totalPointsEarned: json['total_points_earned'] ?? 0,
    );
  }
}

class ExerciseProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  
  ExerciseStats? _writingStats;
  ExerciseStats? _speakingStats;
  OverallStats? _overallStats;
  bool _isLoading = false;

  ExerciseProvider(this._apiClient);

  ExerciseStats? get writingStats => _writingStats;
  ExerciseStats? get speakingStats => _speakingStats;
  OverallStats? get overallStats => _overallStats;
  bool get isLoading => _isLoading;

  Future<void> fetchExerciseStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/exercises/stats');
      _writingStats = ExerciseStats.fromJson(response.data['writing']);
      _speakingStats = ExerciseStats.fromJson(response.data['speaking']);
      _overallStats = OverallStats.fromJson(response.data['stats']);
    } catch (e) {
      debugPrint("Error fetching exercise stats: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
