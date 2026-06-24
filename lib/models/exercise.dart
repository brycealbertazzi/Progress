import 'workout_log.dart';

class Exercise {
  final String id;
  String name;
  final String muscleGroup;
  final List<WorkoutLog> logs;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.logs = const [],
  });
}
