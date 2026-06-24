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
}
