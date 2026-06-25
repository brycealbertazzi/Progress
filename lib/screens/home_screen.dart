import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../models/exercise_type.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/bodyweight_badge.dart';
import '../widgets/create_exercise_sheet.dart';
import '../widgets/swipe_to_delete_card.dart';
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
    showModalBottomSheet<({String name, ExerciseType exerciseType, bool isBodyweightOnly})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateExerciseSheet(),
    ).then((result) async {
      if (result == null) return;
      try {
        final exercise = await DatabaseService.instance.createExercise(
          result.name,
          result.exerciseType,
          result.isBodyweightOnly,
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

  Future<void> _deleteAccount() async {
    try {
      await DatabaseService.instance.deleteAllUserData();
      await AuthService.instance.deleteAccount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              'Delete Account',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'All your exercises, workout logs, and account data will be permanently deleted.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _deleteAccount();
    });
  }

  Widget _buildAvatar() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final avatarUrl = meta?['avatar_url'] as String? ?? meta?['picture'] as String?;
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'sign_out') {
          _signOut();
        } else if (value == 'delete_account') {
          _showDeleteConfirmation();
        }
      },
      offset: const Offset(0, 8),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => const [
        PopupMenuItem<String>(
          value: 'sign_out',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Sign Out', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete_account',
          child: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red, size: 18),
              SizedBox(width: 10),
              Text('Delete Account', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF6C63FF),
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildAvatar(),
          ),
        ],
      ),
      body: _buildBody(),
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
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _loadExercises,
                child: const Text('Retry',
                    style: TextStyle(color: Color(0xFF6C63FF), fontSize: 15)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _exercises.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 56),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises yet',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to add your first exercise',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return SwipeToDeleteCard(
                      key: ValueKey(exercise.id),
                      onTap: () => _openDetail(exercise),
                      onDeleteConfirmed: () {
                        setState(() => _exercises.removeAt(index));
                        DatabaseService.instance.deleteExercise(exercise.id);
                      },
                      deleteTitle: 'Delete Exercise',
                      deleteMessage:
                          'Delete "${exercise.name}" and all its logs?',
                      bottomMargin: 12,
                      child: _ExerciseCardContent(exercise: exercise),
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
          child: GestureDetector(
            onTap: _showCreateSheet,
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
                    'Add Exercise',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExerciseCardContent extends StatelessWidget {
  const _ExerciseCardContent({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (exercise.isBodyweightOnly) ...[
                  const SizedBox(width: 8),
                  BodyweightBadge(
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
