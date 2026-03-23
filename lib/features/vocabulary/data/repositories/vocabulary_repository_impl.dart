import '../../../../core/network/api_client.dart';
import '../models/vocabulary_model.dart';
import '../models/vocabulary_theme_model.dart';
import '../../domain/repositories/vocabulary_repository.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final ApiClient _apiClient;

  VocabularyRepositoryImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getThemes() async {
    final response = await _apiClient.get('/vocabulary/themes');
    final List themesList = response.data['themes'];
    final summary = response.data['summary'];
    
    return {
      'themes': themesList.map((json) => VocabularyThemeModel.fromJson(json)).toList(),
      'summary': summary,
    };
  }

  @override
  Future<Map<String, dynamic>> getVocabularies(int themeId) async {
    final response = await _apiClient.get('/vocabulary/themes/$themeId');
    final List vocabList = response.data['vocabularies'];
    
    return {
      'theme_name': response.data['theme_name'],
      'vocabularies': vocabList.map((json) => VocabularyModel.fromJson(json)).toList(),
    };
  }

  @override
  Future<bool> completeVocabulary(int vocabId) async {
    try {
      await _apiClient.post('/vocabulary/$vocabId/complete');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<VocabularyThemeModel>> getContinueLearning() async {
    final response = await _apiClient.get('/vocabulary/continue-learning');
    final List themesList = response.data['themes'];
    return themesList.map((json) => VocabularyThemeModel.fromJson(json)).toList();
  }
}
