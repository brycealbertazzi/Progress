class WorkoutLog {
  final String? id;
  final DateTime date;
  final double weight;
  final int totalReps;
  final int? totalTime; // seconds — time-based exercises only
  final bool isHoursUsed;

  const WorkoutLog({
    this.id,
    required this.date,
    this.weight = 0,
    this.totalReps = 0,
    this.totalTime,
    this.isHoursUsed = false,
  });

  double get volume {
    if (totalTime != null) {
      return weight > 0 ? weight * totalTime! : totalTime!.toDouble();
    }
    return weight > 0 ? weight * totalReps : totalReps.toDouble();
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String?,
        date: DateTime.parse(json['date'] as String),
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        totalReps: (json['total_reps'] as int?) ?? 0,
        totalTime: json['total_time'] as int?,
        isHoursUsed: (json['is_hours_used'] as bool?) ?? false,
      );

  Map<String, dynamic> toInsertJson(String exerciseId, String userId) => {
        'exercise_id': exerciseId,
        'user_id': userId,
        'date': _dateString(date),
        'weight': weight,
        'total_reps': totalReps,
        if (totalTime != null) 'total_time': totalTime,
        'is_hours_used': isHoursUsed,
      };

  Map<String, dynamic> toUpdateJson() => {
        'date': _dateString(date),
        'weight': weight,
        'total_reps': totalReps,
        'total_time': totalTime,
        'is_hours_used': isHoursUsed,
      };

  WorkoutLog copyWith({String? id}) => WorkoutLog(
        id: id ?? this.id,
        date: date,
        weight: weight,
        totalReps: totalReps,
        totalTime: totalTime,
        isHoursUsed: isHoursUsed,
      );

  static String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
