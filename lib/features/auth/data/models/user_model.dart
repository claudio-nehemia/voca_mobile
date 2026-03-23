import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.role,
    required super.className,
    required super.score,
    required super.progressPercentage,
    required super.rank,
    required super.wordsLearned,
    required super.totalWords,
    required super.exercisesDone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      className: json['class'] ?? 'Class 10-A',
      score: json['score'] ?? 0,
      progressPercentage: json['progress_percentage'] ?? 0,
      rank: json['rank'] ?? 0,
      wordsLearned: json['words_learned'] ?? 0,
      totalWords: json['total_words'] ?? 0,
      exercisesDone: json['exercises_done'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'class': className,
      'score': score,
      'progress_percentage': progressPercentage,
      'rank': rank,
      'words_learned': wordsLearned,
      'total_words': totalWords,
      'exercises_done': exercisesDone,
    };
  }
}
