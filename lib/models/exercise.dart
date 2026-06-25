import 'exercise_type.dart';
import 'workout_log.dart';

class Exercise {
  final String id;
  String name;
  final ExerciseType exerciseType;
  bool isBodyweightOnly;
  final List<WorkoutLog> logs;
  String? groupId;
  int orderIndex;

  Exercise({
    required this.id,
    required this.name,
    required this.exerciseType,
    this.isBodyweightOnly = false,
    this.logs = const [],
    this.groupId,
    this.orderIndex = 0,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, List<WorkoutLog> logs) =>
      Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        exerciseType: (json['exercise_type'] as String?) == 'timeBased'
            ? ExerciseType.timeBased
            : ExerciseType.repBased,
        isBodyweightOnly: (json['is_bodyweight_only'] as bool?) ?? false,
        logs: logs,
        groupId: json['group_id'] as String?,
        orderIndex: (json['order_index'] as int?) ?? 0,
      );
}
