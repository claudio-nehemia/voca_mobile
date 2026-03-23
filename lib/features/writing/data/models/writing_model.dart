import '../../domain/entities/writing_entity.dart';

class WritingModel extends WritingEntity {
  WritingModel({
    required super.id,
    required super.themeName,
    required super.title,
    required super.instruction,
    required super.point,
    required super.isDone,
    super.answer,
  });

  factory WritingModel.fromJson(Map<String, dynamic> json) {
    return WritingModel(
      id: json['id'],
      themeName: json['theme_name'] ?? 'Guided Task',
      title: json['title'],
      instruction: json['instruction'],
      point: json['point'],
      isDone: json['is_done'] ?? false,
      answer: json['answer'],
    );
  }
}
