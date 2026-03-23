import '../../domain/entities/vocabulary_theme_entity.dart';

class VocabularyThemeModel extends VocabularyThemeEntity {
  VocabularyThemeModel({
    required super.id,
    required super.name,
    required super.totalWords,
    required super.doneWords,
    required super.progressPercentage,
  });

  factory VocabularyThemeModel.fromJson(Map<String, dynamic> json) {
    return VocabularyThemeModel(
      id: json['id'],
      name: json['name'],
      totalWords: json['total_words'],
      doneWords: json['done_words'],
      progressPercentage: json['progress_percentage'] ?? json['progress'] ?? 0,
    );
  }
}
