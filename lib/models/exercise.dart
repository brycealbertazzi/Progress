import 'exercise_type.dart';
import 'workout_log.dart';

class Exercise {
  final String id;
  String name;
  final String muscleGroup;
  final ExerciseType exerciseType;
  final List<WorkoutLog> logs;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.exerciseType,
    this.logs = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json, List<WorkoutLog> logs) =>
      Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        muscleGroup: (json['muscle_group'] as String?) ?? '',
        exerciseType: (json['exercise_type'] as String?) == 'timeBased'
            ? ExerciseType.timeBased
            : ExerciseType.repBased,
        logs: logs,
      );
}
