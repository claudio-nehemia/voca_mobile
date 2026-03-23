import '../entities/speaking_entity.dart';

abstract class SpeakingRepository {
  Future<List<SpeakingEntity>> getSpeakings();
  Future<Map<String, dynamic>> submitRecording(int speakingId, String filePath);
  Future<SpeakingEntity> getSpeakingDetail(int id);
}
