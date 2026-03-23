import '../../domain/entities/vocabulary_entity.dart';

class VocabularyModel extends VocabularyEntity {
  VocabularyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.goals,
    super.audioUrl,
    required super.point,
    super.isLearned,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      goals: json['goals'] ?? '',
      audioUrl: json['audio_url'],
      point: json['point'] ?? 0,
      isLearned: json['is_learned'] ?? false,
    );
  }
}
