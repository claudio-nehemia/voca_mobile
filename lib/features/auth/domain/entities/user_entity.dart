class UserEntity {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String className;
  final int score;
  final int progressPercentage;
  final int rank;
  final int wordsLearned;
  final int totalWords;
  final int exercisesDone;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    required this.className,
    required this.score,
    required this.progressPercentage,
    required this.rank,
    required this.wordsLearned,
    required this.totalWords,
    required this.exercisesDone,
  });
}
