import '../../domain/entities/vocabulary_entity.dart';
import '../../domain/entities/vocabulary_theme_entity.dart';

abstract class VocabularyRepository {
  Future<Map<String, dynamic>> getThemes();
  Future<Map<String, dynamic>> getVocabularies(int themeId);
  Future<bool> completeVocabulary(int vocabId);
  Future<List<VocabularyThemeEntity>> getContinueLearning();
}
