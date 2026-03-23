import 'package:flutter/foundation.dart';
import '../../domain/entities/vocabulary_entity.dart';
import '../../domain/entities/vocabulary_theme_entity.dart';
import '../../domain/repositories/vocabulary_repository.dart';

class VocabularyProvider with ChangeNotifier {
  final VocabularyRepository _repository;

  VocabularyProvider(this._repository);

  List<VocabularyThemeEntity> _themes = [];
  Map<String, dynamic> _summary = {};
  bool _isLoadingThemes = false;

  List<VocabularyThemeEntity> get themes => _themes;
  Map<String, dynamic> get summary => _summary;
  bool get isLoadingThemes => _isLoadingThemes;

  List<VocabularyEntity> _vocabularies = [];
  String _currentThemeName = '';
  bool _isLoadingVocabularies = false;

  List<VocabularyEntity> get vocabularies => _vocabularies;
  String get currentThemeName => _currentThemeName;
  bool get isLoadingVocabularies => _isLoadingVocabularies;

  List<VocabularyThemeEntity> _continueLearningThemes = [];
  bool _isLoadingContinue = false;

  List<VocabularyThemeEntity> get continueLearningThemes => _continueLearningThemes;
  bool get isLoadingContinue => _isLoadingContinue;

  Future<void> fetchThemes() async {
    _isLoadingThemes = true;
    notifyListeners();
    try {
      final data = await _repository.getThemes();
      _themes = List<VocabularyThemeEntity>.from(data['themes']);
      _summary = data['summary'];
    } catch (e) {
      if (kDebugMode) print('Error fetching themes: $e');
    } finally {
      _isLoadingThemes = false;
      notifyListeners();
    }
  }

  Future<void> fetchVocabularies(int themeId) async {
    _isLoadingVocabularies = true;
    _vocabularies = [];
    notifyListeners();
    try {
      final data = await _repository.getVocabularies(themeId);
      _currentThemeName = data['theme_name'];
      _vocabularies = List<VocabularyEntity>.from(data['vocabularies']);
    } catch (e) {
      if (kDebugMode) print('Error fetching vocabularies: $e');
    } finally {
      _isLoadingVocabularies = false;
      notifyListeners();
    }
  }

  Future<bool> completeVocabulary(int vocabId) async {
    final success = await _repository.completeVocabulary(vocabId);
    if (success) {
      // Update local state
      final index = _vocabularies.indexWhere((v) => v.id == vocabId);
      if (index != -1) {
        final v = _vocabularies[index];
        _vocabularies[index] = VocabularyEntity(
          id: v.id,
          title: v.title,
          description: v.description,
          goals: v.goals,
          audioUrl: v.audioUrl,
          point: v.point,
          isLearned: true,
        );
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<void> fetchContinueLearning() async {
    _isLoadingContinue = true;
    notifyListeners();
    try {
      _continueLearningThemes = await _repository.getContinueLearning();
    } catch (e) {
      if (kDebugMode) print('Error fetching continue learning: $e');
    } finally {
      _isLoadingContinue = false;
      notifyListeners();
    }
  }
}
