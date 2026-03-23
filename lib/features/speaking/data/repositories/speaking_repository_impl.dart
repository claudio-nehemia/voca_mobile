import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/speaking_entity.dart';
import '../../domain/repositories/speaking_repository.dart';
import '../models/speaking_model.dart';

class SpeakingRepositoryImpl implements SpeakingRepository {
  final ApiClient _apiClient;

  SpeakingRepositoryImpl(this._apiClient);

  @override
  Future<List<SpeakingEntity>> getSpeakings() async {
    try {
      final response = await _apiClient.get('/speakings');
      final List list = response.data['exercises'];
      return list.map((json) => SpeakingModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SpeakingEntity> getSpeakingDetail(int id) async {
    try {
      final response = await _apiClient.get('/speakings/$id');
      return SpeakingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitRecording(int speakingId, String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('audio', 'm4a'),
        ),
      });

      final response = await _apiClient.post(
        '/speakings/$speakingId/submit',
        data: formData,
      );
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
