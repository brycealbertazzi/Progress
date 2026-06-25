import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';
import '../services/database_service.dart';
import '../widgets/add_log_sheet.dart';
import '../widgets/bodyweight_badge.dart';
import '../widgets/swipe_to_delete_card.dart';
import '../widgets/volume_chart_sheet.dart';

class ExerciseDetailScreen extends StatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late String _name;
  late bool _isBodyweightOnly;
  late List<WorkoutLog> _logs;

  @override
  void initState() {
    super.initState();
    _name = widget.exercise.name;
    _isBodyweightOnly = widget.exercise.isBodyweightOnly;
    _logs = List.from(widget.exercise.logs);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<MapEntry<DateTime, List<WorkoutLog>>> get _groupedLogs {
    final sorted = [..._logs]..sort((a, b) => b.date.compareTo(a.date));
    final ordered = <String, MapEntry<DateTime, List<WorkoutLog>>>{};
    for (final log in sorted) {
      final key = _dateKey(log.date);
      if (!ordered.containsKey(key)) {
        ordered[key] = MapEntry(log.date, []);
      }
      ordered[key]!.value.add(log);
    }
    return ordered.values.toList();
  }

  void _showEditDialog() {
    final controller = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Rename Exercise', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF6C63FF),
          decoration: InputDecoration(
            hintText: 'Exercise name',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6C63FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () async {
              final trimmed = controller.text.trim();
              Navigator.pop(context);
              if (trimmed.isEmpty || trimmed == _name) return;
              setState(() {
                _name = trimmed;
                widget.exercise.name = trimmed;
              });
              final messenger = ScaffoldMessenger.of(context);
              try {
                await DatabaseService.instance.updateExercise(
                  widget.exercise.id,
                  name: trimmed,
                  isBodyweightOnly: _isBodyweightOnly,
                );
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                      SnackBar(content: Text('Failed to rename: $e')));
                }
              }
            },
            child: const Text('Save',
                style: TextStyle(color: Color(0xFF6C63FF))),
          ),
        ],
      ),
    );
  }

  void _showAddLogSheet() {
    showModalBottomSheet<WorkoutLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLogSheet(
        exerciseType: widget.exercise.exerciseType,
        isBodyweightOnly: _isBodyweightOnly,
      ),
    ).then((log) async {
      if (log == null) return;
      try {
        final saved =
            await DatabaseService.instance.addLog(widget.exercise.id, log);
        setState(() => _logs.add(saved));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save log: $e')),
          );
        }
      }
    });
  }

  void _editLog(WorkoutLog original) {
    showModalBottomSheet<WorkoutLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLogSheet(
        exerciseType: widget.exercise.exerciseType,
        isBodyweightOnly: _isBodyweightOnly,
        initialLog: original,
      ),
    ).then((updated) async {
      if (updated == null) return;
      final withId = updated.copyWith(id: original.id);
      try {
        await DatabaseService.instance.updateLog(withId);
        setState(() {
          final index = _logs.indexOf(original);
          if (index != -1) _logs[index] = withId;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update log: $e')),
          );
        }
      }
    });
  }

  void _showVolumeChart() {
    // Pass an exercise with current local logs so the chart reflects unsaved changes
    final exerciseForChart = Exercise(
      id: widget.exercise.id,
      name: _name,
      exerciseType: widget.exercise.exerciseType,
      isBodyweightOnly: _isBodyweightOnly,
      logs: _logs,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, controller) =>
            VolumeChartSheet(exercise: exerciseForChart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedLogs;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isBodyweightOnly) ...[
              const SizedBox(width: 8),
              BodyweightBadge(
                size: 18,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Color(0xFF6C63FF), size: 22),
            tooltip: 'Rename',
            onPressed: _showEditDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: groups.isEmpty
                ? const Center(
                    child: Text(
                      'No sessions logged yet',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: [
                      for (final group in groups) ...[
                        _DatePill(date: group.key),
                        for (final log in group.value)
                          SwipeToDeleteCard(
                            key: ValueKey(log.id ?? log.hashCode),
                            onTap: () => _editLog(log),
                            onDeleteConfirmed: () {
                              setState(() => _logs.remove(log));
                              if (log.id != null) {
                                DatabaseService.instance.deleteLog(log.id!);
                              }
                            },
                            deleteTitle: 'Delete Log',
                            deleteMessage: 'Remove this session?',
                            bottomMargin: 10,
                            child: _WorkoutLogCardContent(
                              log: log,
                              exerciseType: widget.exercise.exerciseType,
                              isBodyweightOnly: _isBodyweightOnly,
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _AddLogButton(onTap: _showAddLogSheet),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: _GraphButton(onTap: _showVolumeChart),
          ),
        ],
      ),
    );
  }
}

class _WorkoutLogCardContent extends StatelessWidget {
  const _WorkoutLogCardContent({
    required this.log,
    required this.exerciseType,
    this.isBodyweightOnly = false,
  });

  final WorkoutLog log;
  final ExerciseType exerciseType;
  final bool isBodyweightOnly;

  bool get _isTimeBased => exerciseType == ExerciseType.timeBased;

  String _primaryValue() {
    if (_isTimeBased && !isBodyweightOnly) {
      return '${_formatNumber(log.volume.toInt())} lbs·s';
    }
    if (_isTimeBased) return _formatTime(log.totalTime ?? 0);
    if (!isBodyweightOnly) {
      return '${_formatNumber(log.volume.toInt())} lbs·reps';
    }
    return '${log.totalReps} reps';
  }

  String _secondaryValue() {
    if (_isTimeBased && !isBodyweightOnly) {
      return '${_stripTrailingZero(log.weight)} lbs · ${_formatTime(log.totalTime ?? 0)}';
    }
    return '${_stripTrailingZero(log.weight)} lbs · ${log.totalReps} reps';
  }

  String _formatNumber(int n) =>
      n >= 1000 ? '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}' : '$n';

  String _stripTrailingZero(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isBodyweightOnly) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Center(
          child: Text(
            _primaryValue(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _secondaryValue(),
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
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.date});
  final DateTime date;

  String _format(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 16, bottom: 6),
      child: Text(
        _format(date),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AddLogButton extends StatelessWidget {
  const _AddLogButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Add Log',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphButton extends StatelessWidget {
  const _GraphButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded, color: Color(0xFF6C63FF), size: 22),
            SizedBox(width: 10),
            Text(
              'View Progress',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
