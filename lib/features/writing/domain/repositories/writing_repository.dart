import '../entities/writing_entity.dart';

abstract class WritingRepository {
  Future<List<WritingEntity>> getWritings();
  Future<Map<String, dynamic>> submitAnswer(int writingId, String answer);
}
