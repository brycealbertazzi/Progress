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
    ExerciseType type,
    bool isBodyweightOnly,
    int orderIndex,
  ) async {
    final data = await _client.from('exercises').insert({
      'name': name,
      'exercise_type': type == ExerciseType.timeBased ? 'timeBased' : 'repBased',
      'is_bodyweight_only': isBodyweightOnly,
      'user_id': _uid,
      'order_index': orderIndex,
    }).select().single();

    return Exercise.fromJson(data, []);
  }

  Future<void> updateExercise(
      String id, {required String name, required bool isBodyweightOnly}) async {
    await _client.from('exercises').update({
      'name': name,
      'is_bodyweight_only': isBodyweightOnly,
    }).eq('id', id);
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

  Future<void> deleteExercise(String id) async {
    await _client.from('exercises').delete().eq('id', id);
  }

  Future<void> deleteLog(String id) async {
    await _client.from('workout_logs').delete().eq('id', id);
  }

  Future<void> deleteAllUserData() async {
    await Future.wait([
      _client.from('workout_logs').delete().eq('user_id', _uid),
      _client.from('exercises').delete().eq('user_id', _uid),
    ]);
  }
}
