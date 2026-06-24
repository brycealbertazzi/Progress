import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../models/workout_log.dart';
import '../widgets/create_exercise_sheet.dart';
import 'exercise_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Exercise> _exercises = [
    Exercise(
      id: '1',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      exerciseType: ExerciseType.repBased,
      logs: [
        WorkoutLog(date: DateTime(2026, 5, 5),  weight: 135, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 8),  weight: 140, totalReps: 24, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 12), weight: 140, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 15), weight: 145, totalReps: 24, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 19), weight: 145, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 22), weight: 150, totalReps: 24, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 26), weight: 150, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 29), weight: 155, totalReps: 24, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 2),  weight: 155, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 5),  weight: 160, totalReps: 24, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 9),  weight: 160, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 12), weight: 165, totalReps: 24, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 16), weight: 165, totalReps: 30, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 19), weight: 170, totalReps: 24, sets: 3),
      ],
    ),
    Exercise(
      id: '2',
      name: 'Squat',
      muscleGroup: 'Legs',
      exerciseType: ExerciseType.repBased,
      logs: [
        WorkoutLog(date: DateTime(2026, 5, 6),  weight: 185, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 10), weight: 195, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 13), weight: 195, totalReps: 20, sets: 4),
        WorkoutLog(date: DateTime(2026, 5, 17), weight: 205, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 20), weight: 205, totalReps: 20, sets: 4),
        WorkoutLog(date: DateTime(2026, 5, 24), weight: 215, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 27), weight: 215, totalReps: 20, sets: 4),
        WorkoutLog(date: DateTime(2026, 5, 31), weight: 225, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 3),  weight: 225, totalReps: 20, sets: 4),
        WorkoutLog(date: DateTime(2026, 6, 7),  weight: 235, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 10), weight: 235, totalReps: 20, sets: 4),
        WorkoutLog(date: DateTime(2026, 6, 14), weight: 245, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 17), weight: 245, totalReps: 20, sets: 4),
        WorkoutLog(date: DateTime(2026, 6, 21), weight: 255, totalReps: 15, sets: 3),
      ],
    ),
    Exercise(
      id: '3',
      name: 'Deadlift',
      muscleGroup: 'Back',
      exerciseType: ExerciseType.repBased,
      logs: [
        WorkoutLog(date: DateTime(2026, 5, 7),  weight: 225, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 14), weight: 235, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 21), weight: 245, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 28), weight: 255, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 4),  weight: 265, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 11), weight: 275, totalReps: 15, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 18), weight: 285, totalReps: 15, sets: 3),
      ],
    ),
    Exercise(
      id: '4',
      name: 'Deadhang',
      muscleGroup: 'Grip',
      exerciseType: ExerciseType.timeBased,
      logs: [
        WorkoutLog(date: DateTime(2026, 5, 10), totalTime: 45, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 14), totalTime: 50, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 18), totalTime: 55, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 22), totalTime: 60, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 26), totalTime: 65, sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 30), totalTime: 70, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 3),  totalTime: 75, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 7),  totalTime: 80, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 11), totalTime: 82, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 15), totalTime: 85, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 19), totalTime: 88, sets: 3),
      ],
    ),
    Exercise(
      id: '5',
      name: 'Plank',
      muscleGroup: 'Core',
      exerciseType: ExerciseType.timeBased,
      logs: [
        WorkoutLog(date: DateTime(2026, 5, 8),  totalTime: 60,  sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 12), totalTime: 65,  sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 16), totalTime: 70,  sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 20), totalTime: 75,  sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 24), totalTime: 80,  sets: 3),
        WorkoutLog(date: DateTime(2026, 5, 28), totalTime: 85,  sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 1),  totalTime: 90,  sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 5),  totalTime: 95,  sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 9),  totalTime: 100, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 13), totalTime: 105, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 17), totalTime: 110, sets: 3),
        WorkoutLog(date: DateTime(2026, 6, 21), totalTime: 115, sets: 3),
      ],
    ),
  ];

  void _openDetail(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(exercise: exercise),
      ),
    ).then((_) => setState(() {}));
  }

  void _showCreateSheet() {
    showModalBottomSheet<({String name, ExerciseType exerciseType})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateExerciseSheet(),
    ).then((result) {
      if (result == null) return;
      final exercise = Exercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result.name,
        muscleGroup: '',
        exerciseType: result.exerciseType,
        logs: [],
      );
      setState(() => _exercises.add(exercise));
      _openDetail(exercise);
    });
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _exercises.length,
        itemBuilder: (context, index) => _ExerciseCard(
          exercise: _exercises[index],
          onTap: () => _openDetail(_exercises[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSheet,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.muscleGroup,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
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
