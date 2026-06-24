class WorkoutLog {
  final DateTime date;
  final double weight;
  final int totalReps;
  final int sets;

  const WorkoutLog({
    required this.date,
    required this.weight,
    required this.totalReps,
    required this.sets,
  });

  double get volume => weight * totalReps;
}
