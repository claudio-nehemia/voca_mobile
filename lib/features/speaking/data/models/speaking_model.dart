import '../../domain/entities/speaking_entity.dart';

class SpeakingModel extends SpeakingEntity {
  SpeakingModel({
    required super.id,
    required super.jenisName,
    required super.title,
    required super.instruction,
    required super.point,
    required super.isDone,
    super.audioUrl,
  });

  factory SpeakingModel.fromJson(Map<String, dynamic> json) {
    return SpeakingModel(
      id: json['id'],
      jenisName: json['jenis_name'] ?? 'General',
      title: json['title'],
      instruction: json['instruction'],
      point: json['point'],
      isDone: json['is_done'] ?? false,
      audioUrl: json['audio_url'],
    );
  }
}
