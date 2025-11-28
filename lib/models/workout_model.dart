class WorkoutModel {
  final String id;
  final DateTime date;
  final String description;
  final int? duration; // хвилини
  final String? type;
  WorkoutModel(
      {required this.id,
      required this.date,
      required this.description,
      this.duration,
      this.type});
  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'description': description,
        'duration': duration,
        'type': type,
      };
}
