import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../models/exercise_group.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  final _client = Supabase.instance.client;
  String get _uid => _client.auth.currentUser!.id;

  Future<({List<Exercise> exercises, List<ExerciseGroup> groups})> loadData() async {
    final results = await Future.wait([
      _client.from('exercises').select().eq('user_id', _uid).order('order_index'),
      _client.from('workout_logs').select().eq('user_id', _uid).order('date'),
      _client.from('exercise_groups').select().eq('user_id', _uid).order('order_index'),
    ]);

    final exercisesData = results[0] as List<dynamic>;
    final logsData = results[1] as List<dynamic>;
    final groupsData = results[2] as List<dynamic>;

    final logsByExercise = <String, List<WorkoutLog>>{};
    for (final row in logsData) {
      final exerciseId = row['exercise_id'] as String;
      logsByExercise.putIfAbsent(exerciseId, () => []);
      logsByExercise[exerciseId]!
          .add(WorkoutLog.fromJson(row as Map<String, dynamic>));
    }

    final exercises = exercisesData
        .map((e) => Exercise.fromJson(
              e as Map<String, dynamic>,
              logsByExercise[e['id']] ?? [],
            ))
        .toList();

    final groups = groupsData
        .map((g) => ExerciseGroup.fromJson(g as Map<String, dynamic>))
        .toList();

    return (exercises: exercises, groups: groups);
  }

  // Keep for backward compatibility — screens that only need exercises
  Future<List<Exercise>> loadExercises() async {
    final data = await loadData();
    return data.exercises;
  }

  Future<Exercise> createExercise(
    String name,
    ExerciseType type,
    bool isBodyweightOnly,
    int orderIndex, {
    String? groupId,
  }) async {
    final data = await _client.from('exercises').insert({
      'name': name,
      'exercise_type': type == ExerciseType.timeBased ? 'timeBased' : 'repBased',
      'is_bodyweight_only': isBodyweightOnly,
      'user_id': _uid,
      'order_index': orderIndex,
      'group_id': groupId,
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

  Future<void> reorderExercise(String id, int orderIndex) async {
    await _client
        .from('exercises')
        .update({'order_index': orderIndex}).eq('id', id);
  }

  Future<void> moveExerciseToGroup(
      String exerciseId, String? groupId, int orderIndex) async {
    await _client.from('exercises').update({
      'group_id': groupId,
      'order_index': orderIndex,
    }).eq('id', exerciseId);
  }

  Future<ExerciseGroup> createGroup(
    String name, {
    String? parentGroupId,
    required int orderIndex,
  }) async {
    final data = await _client.from('exercise_groups').insert({
      'name': name,
      'user_id': _uid,
      'parent_group_id': parentGroupId,
      'order_index': orderIndex,
    }).select().single();
    return ExerciseGroup.fromJson(data);
  }

  Future<void> renameGroup(String id, String name) async {
    await _client.from('exercise_groups').update({'name': name}).eq('id', id);
  }

  Future<void> deleteGroup(String id) async {
    await _client.from('exercise_groups').delete().eq('id', id);
  }

  Future<void> reorderGroup(String id, int orderIndex) async {
    await _client
        .from('exercise_groups')
        .update({'order_index': orderIndex}).eq('id', id);
  }

  Future<void> moveGroupToParent(
      String groupId, String? parentGroupId, int orderIndex) async {
    await _client.from('exercise_groups').update({
      'parent_group_id': parentGroupId,
      'order_index': orderIndex,
    }).eq('id', groupId);
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
      _client.from('exercise_groups').delete().eq('user_id', _uid),
    ]);
  }
}
