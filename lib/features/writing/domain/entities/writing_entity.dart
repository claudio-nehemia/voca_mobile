class WritingEntity {
  final int id;
  final String themeName;
  final String title;
  final String instruction;
  final int point;
  final bool isDone;
  final String? answer;

  WritingEntity({
    required this.id,
    required this.themeName,
    required this.title,
    required this.instruction,
    required this.point,
    required this.isDone,
    this.answer,
  });
}
