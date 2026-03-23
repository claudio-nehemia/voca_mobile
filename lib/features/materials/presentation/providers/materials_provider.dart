import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';

class MaterialEntity {
  final int id;
  final String name;
  final String description;
  final String fileUrl;

  MaterialEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.fileUrl,
  });

  factory MaterialEntity.fromJson(Map<String, dynamic> json) {
    return MaterialEntity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      fileUrl: json['file_url'],
    );
  }
}

class MaterialsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  List<MaterialEntity> _materials = [];
  bool _isLoading = false;

  MaterialsProvider(this._apiClient);

  List<MaterialEntity> get materials => _materials;
  bool get isLoading => _isLoading;

  Future<void> fetchMaterials() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get('/materials');
      final List list = response.data['materials'] ?? [];
      _materials = list.map((json) => MaterialEntity.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching materials: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
