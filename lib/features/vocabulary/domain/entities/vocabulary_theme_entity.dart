class VocabularyThemeEntity {
  final int id;
  final String name;
  final int totalWords;
  final int doneWords;
  final int progressPercentage;

  VocabularyThemeEntity({
    required this.id,
    required this.name,
    required this.totalWords,
    required this.doneWords,
    required this.progressPercentage,
  });
}
