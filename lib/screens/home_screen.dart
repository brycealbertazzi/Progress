import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/create_exercise_sheet.dart';
import 'exercise_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exercises = await DatabaseService.instance.loadExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _openDetail(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(exercise: exercise),
      ),
    ).then((_) => _loadExercises());
  }

  void _showCreateSheet() {
    showModalBottomSheet<({String name, ExerciseType exerciseType})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateExerciseSheet(),
    ).then((result) async {
      if (result == null) return;
      try {
        final exercise = await DatabaseService.instance.createExercise(
          result.name,
          '',
          result.exerciseType,
          _exercises.length,
        );
        if (mounted) {
          setState(() => _exercises.add(exercise));
          _openDetail(exercise);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create exercise: $e')),
          );
        }
      }
    });
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
            tooltip: 'Sign out',
            onPressed: _signOut,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSheet,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  color: Colors.white.withValues(alpha: 0.3), size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load exercises',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _loadExercises,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Color(0xFF6C63FF), fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center,
                  color: Colors.white.withValues(alpha: 0.2), size: 56),
              const SizedBox(height: 16),
              Text(
                'No exercises yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to add your first exercise',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _exercises.length,
      itemBuilder: (context, index) => _ExerciseCard(
        exercise: _exercises[index],
        onTap: () => _openDetail(_exercises[index]),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  exercise.exerciseType == ExerciseType.timeBased
                      ? Icons.timer_outlined
                      : Icons.fitness_center,
                  color: const Color(0xFF6C63FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
