import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';
import '../services/database_service.dart';
import '../widgets/add_log_sheet.dart';

class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({
    super.key,
    required this.date,
    required this.entries,
  });

  final DateTime date;

  /// All log entries for this day, each paired with its exercise.
  final List<({WorkoutLog log, Exercise exercise})> entries;

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late List<({WorkoutLog log, Exercise exercise})> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.entries);
  }

  /// Groups entries by exercise, preserving order of first appearance.
  List<({Exercise exercise, List<WorkoutLog> logs})> get _grouped {
    final seen = <String>[];
    final map = <String, ({Exercise exercise, List<WorkoutLog> logs})>{};
    for (final e in _entries) {
      if (!map.containsKey(e.exercise.id)) {
        seen.add(e.exercise.id);
        map[e.exercise.id] = (exercise: e.exercise, logs: []);
      }
      map[e.exercise.id]!.logs.add(e.log);
    }
    return seen.map((id) => map[id]!).toList();
  }

  void _editLog(WorkoutLog original, Exercise exercise) {
    showModalBottomSheet<WorkoutLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLogSheet(
        exerciseType: exercise.exerciseType,
        isBodyweightOnly: exercise.isBodyweightOnly,
        initialLog: original,
      ),
    ).then((updated) async {
      if (updated == null) return;
      final withId = updated.copyWith(id: original.id);
      await DatabaseService.instance.updateLog(withId);
      if (mounted) {
        setState(() {
          _entries = _entries.map((e) {
            if (e.log.id == original.id) return (log: withId, exercise: e.exercise);
            return e;
          }).toList();
        });
      }
    });
  }

  String _formatTitle(DateTime d) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          _formatTitle(widget.date),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (final group in grouped) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 20, bottom: 8),
              child: Text(
                group.exercise.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            for (final log in group.logs)
              _LogCard(
                log: log,
                exercise: group.exercise,
                onTap: () => _editLog(log, group.exercise),
              ),
          ],
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({
    required this.log,
    required this.exercise,
    required this.onTap,
  });

  final WorkoutLog log;
  final Exercise exercise;
  final VoidCallback onTap;

  bool get _isTimeBased => exercise.exerciseType == ExerciseType.timeBased;
  bool get _isBodyweight => exercise.isBodyweightOnly;

  String _primaryValue() {
    if (_isTimeBased && !_isBodyweight) {
      return '${_formatNumber(log.volume.toInt())} lbs·s';
    }
    if (_isTimeBased) return _formatTime(log.totalTime ?? 0, withHours: log.isHoursUsed);
    if (!_isBodyweight) return '${_formatNumber(log.volume.toInt())} lbs·reps';
    return '${log.totalReps} reps';
  }

  String _secondaryValue() {
    if (_isTimeBased && !_isBodyweight) {
      return '${_stripZero(log.weight)} lbs · ${_formatTime(log.totalTime ?? 0, withHours: log.isHoursUsed)}';
    }
    if (!_isBodyweight) {
      return '${_stripZero(log.weight)} lbs · ${log.totalReps} reps';
    }
    return '';
  }

  String _formatNumber(int n) =>
      n >= 1000 ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}' : '$n';

  String _stripZero(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  String _formatTime(int seconds, {bool withHours = false}) {
    if (withHours) {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final secondary = _secondaryValue();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: secondary.isEmpty
            ? Center(
                child: Text(
                  _primaryValue(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    secondary,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _primaryValue(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
