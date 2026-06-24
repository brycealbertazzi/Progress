class WorkoutLog {
  final DateTime date;
  final double weight;
  final int totalReps;
  final int sets;
  final int? totalTime; // seconds — time-based exercises only

  const WorkoutLog({
    required this.date,
    this.weight = 0,
    this.totalReps = 0,
    required this.sets,
    this.totalTime,
  });

  double get volume =>
      totalTime != null ? totalTime!.toDouble() : weight * totalReps;
}
