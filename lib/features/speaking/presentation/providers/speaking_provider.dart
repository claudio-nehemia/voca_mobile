import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/speaking_entity.dart';
import '../../domain/repositories/speaking_repository.dart';

class SpeakingProvider extends ChangeNotifier {
  final SpeakingRepository _repository;
  final _recorder = AudioRecorder();

  List<SpeakingEntity> _exercises = [];
  bool _isFetching = false;
  bool _isRecording = false;
  bool _isSubmitting = false;
  String? _recordedPath;
  int _recordDuration = 0;
  Timer? _timer;

  SpeakingProvider(this._repository);

  List<SpeakingEntity> get exercises => _exercises;
  bool get isFetching => _isFetching;
  bool get isRecording => _isRecording;
  bool get isSubmitting => _isSubmitting;
  String? get recordedPath => _recordedPath;
  int get recordDuration => _recordDuration;

  Future<void> fetchSpeakings() async {
    _isFetching = true;
    notifyListeners();
    try {
      _exercises = await _repository.getSpeakings();
    } catch (e) {
      debugPrint("Error fetching speakings: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        const config = RecordConfig();
        await _recorder.start(config, path: path);
        
        _isRecording = true;
        _recordedPath = null;
        _recordDuration = 0;
        _startTimer();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
      notifyListeners();
    });
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _timer?.cancel();
      _recordedPath = path;
      notifyListeners();
      return path;
    } catch (e) {
      debugPrint("Error stopping recording: $e");
      _isRecording = false;
      _timer?.cancel();
      notifyListeners();
      return null;
    }
  }

  Future<bool> submitAnswer(int speakingId) async {
    if (_recordedPath == null) return false;
    
    _isSubmitting = true;
    notifyListeners();
    
    try {
      await _repository.submitRecording(speakingId, _recordedPath!);
      
      // Update locally
      await fetchSpeakings();
      
      return true;
    } catch (e) {
      debugPrint("Error submitting speaking activity: $e");
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
