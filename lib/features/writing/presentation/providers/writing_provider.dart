import 'package:flutter/material.dart';
import '../../domain/entities/writing_entity.dart';
import '../../domain/repositories/writing_repository.dart';
import '../../data/models/writing_model.dart';

class WritingProvider extends ChangeNotifier {
  final WritingRepository _repository;

  List<WritingEntity> _exercises = [];
  bool _isLoading = false;

  WritingProvider(this._repository);

  List<WritingEntity> get exercises => _exercises;
  bool get isLoading => _isLoading;

  Future<void> fetchWritings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _repository.getWritings();
    } catch (e) {
      debugPrint("Error fetching writings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitAnswer(int writingId, String answer) async {
    try {
      final result = await _repository.submitAnswer(writingId, answer);
      debugPrint("Submit result: $result");
      
      // Update locally
      final index = _exercises.indexWhere((e) => e.id == writingId);
      if (index != -1) {
        _exercises[index] = WritingModel(
          id: _exercises[index].id,
          themeName: _exercises[index].themeName,
          title: _exercises[index].title,
          instruction: _exercises[index].instruction,
          point: _exercises[index].point,
          isDone: true,
          answer: answer,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error submitting writing: $e");
      return false;
    }
  }
}
