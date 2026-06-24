import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  final _client = Supabase.instance.client;
  String get _uid => _client.auth.currentUser!.id;

  Future<List<Exercise>> loadExercises() async {
    final results = await Future.wait([
      _client.from('exercises').select().eq('user_id', _uid).order('order_index'),
      _client.from('workout_logs').select().eq('user_id', _uid).order('date'),
    ]);

    final exercisesData = results[0] as List<dynamic>;
    final logsData = results[1] as List<dynamic>;

    final logsByExercise = <String, List<WorkoutLog>>{};
    for (final row in logsData) {
      final exerciseId = row['exercise_id'] as String;
      logsByExercise.putIfAbsent(exerciseId, () => []);
      logsByExercise[exerciseId]!.add(WorkoutLog.fromJson(row as Map<String, dynamic>));
    }

    return exercisesData
        .map((e) => Exercise.fromJson(
              e as Map<String, dynamic>,
              logsByExercise[e['id']] ?? [],
            ))
        .toList();
  }

  Future<Exercise> createExercise(
    String name,
    String muscleGroup,
    ExerciseType type,
    int orderIndex,
  ) async {
    final data = await _client.from('exercises').insert({
      'name': name,
      'muscle_group': muscleGroup,
      'exercise_type': type == ExerciseType.timeBased ? 'timeBased' : 'repBased',
      'user_id': _uid,
      'order_index': orderIndex,
    }).select().single();

    return Exercise.fromJson(data, []);
  }

  Future<void> updateExerciseName(String id, String name) async {
    await _client.from('exercises').update({'name': name}).eq('id', id);
  }

  Future<WorkoutLog> addLog(String exerciseId, WorkoutLog log) async {
    final data = await _client
        .from('workout_logs')
        .insert(log.toInsertJson(exerciseId, _uid))
        .select()
        .single();
    return WorkoutLog.fromJson(data);
  }

  Future<void> updateLog(WorkoutLog log) async {
    await _client
        .from('workout_logs')
        .update(log.toUpdateJson())
        .eq('id', log.id!);
  }
}
