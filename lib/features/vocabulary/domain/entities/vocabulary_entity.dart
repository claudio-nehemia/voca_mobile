class VocabularyEntity {
  final int id;
  final String title;
  final String description;
  final String goals;
  final String? audioUrl;
  final int point;
  final bool isLearned;

  VocabularyEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.goals,
    this.audioUrl,
    required this.point,
    this.isLearned = false,
  });
}
