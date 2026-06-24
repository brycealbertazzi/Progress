class WorkoutLog {
  final String? id;
  final DateTime date;
  final double weight;
  final int totalReps;
  final int sets;
  final int? totalTime; // seconds — time-based exercises only

  const WorkoutLog({
    this.id,
    required this.date,
    this.weight = 0,
    this.totalReps = 0,
    required this.sets,
    this.totalTime,
  });

  double get volume =>
      totalTime != null ? totalTime!.toDouble() : weight * totalReps;

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String?,
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        totalReps: (json['total_reps'] as int?) ?? 0,
        sets: (json['sets'] as int?) ?? 0,
        totalTime: json['total_time'] as int?,
      );

  Map<String, dynamic> toInsertJson(String exerciseId, String userId) => {
        'exercise_id': exerciseId,
        'user_id': userId,
        'date': _dateString(date),
        'weight': weight,
        'total_reps': totalReps,
        'sets': sets,
        if (totalTime != null) 'total_time': totalTime,
      };

  Map<String, dynamic> toUpdateJson() => {
        'date': _dateString(date),
        'weight': weight,
        'total_reps': totalReps,
        'sets': sets,
        'total_time': totalTime,
      };

  WorkoutLog copyWith({String? id}) => WorkoutLog(
        id: id ?? this.id,
        date: date,
        weight: weight,
        totalReps: totalReps,
        sets: sets,
        totalTime: totalTime,
      );

  static String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
