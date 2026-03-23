import '../../../../core/network/api_client.dart';
import '../../domain/entities/writing_entity.dart';
import '../../domain/repositories/writing_repository.dart';
import '../models/writing_model.dart';

class WritingRepositoryImpl implements WritingRepository {
  final ApiClient _apiClient;

  WritingRepositoryImpl(this._apiClient);

  @override
  Future<List<WritingEntity>> getWritings() async {
    final response = await _apiClient.get('/writings');
    final List list = response.data['exercises'];
    return list.map((json) => WritingModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> submitAnswer(int writingId, String answer) async {
    final response = await _apiClient.post('/writings/$writingId/submit', data: {
      'answer': answer,
    });
    return response.data;
  }
}
