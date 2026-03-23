class SpeakingEntity {
  final int id;
  final String jenisName;
  final String title;
  final String instruction;
  final int point;
  final bool isDone;
  final String? audioUrl;

  SpeakingEntity({
    required this.id,
    required this.jenisName,
    required this.title,
    required this.instruction,
    required this.point,
    required this.isDone,
    this.audioUrl,
  });
}
