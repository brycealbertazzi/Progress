import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../models/exercise_group.dart';
import '../models/exercise_type.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/bodyweight_badge.dart';
import '../widgets/create_exercise_sheet.dart';
import '../widgets/group_card.dart';
import '../widgets/swipe_to_delete_card.dart';
import '../widgets/calendar_sheet.dart';
import '../widgets/group_name_sheet.dart';
import 'exercise_detail_screen.dart';
import 'group_screen.dart';

sealed class _DragData {}

class _ExerciseDrag extends _DragData {
  final Exercise exercise;
  _ExerciseDrag(this.exercise);
}

class _GroupDrag extends _DragData {
  final ExerciseGroup group;
  _GroupDrag(this.group);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Exercise> _exercises = [];
  List<ExerciseGroup> _groups = [];
  bool _isLoading = true;
  String? _error;
  bool _isJiggleMode = false;
  _DragData? _dragging;
  late final AnimationController _jiggleController;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadData();
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  List<Object> get _rootItems {
    final items = <Object>[
      ..._exercises.where((e) => e.groupId == null),
      ..._groups.where((g) => g.parentGroupId == null),
    ];
    items.sort((a, b) {
      final ai =
          a is Exercise ? a.orderIndex : (a as ExerciseGroup).orderIndex;
      final bi =
          b is Exercise ? b.orderIndex : (b as ExerciseGroup).orderIndex;
      return ai.compareTo(bi);
    });
    return items;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await DatabaseService.instance.loadData();
      setState(() {
        _exercises = data.exercises;
        _groups = data.groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _enterJiggleMode() {
    setState(() => _isJiggleMode = true);
    _jiggleController.repeat();
  }

  void _exitJiggleMode() {
    _jiggleController.stop();
    _jiggleController.reset();
    setState(() {
      _isJiggleMode = false;
      _dragging = null;
    });
  }

  void _openDetail(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)),
    ).then((_) => _loadData());
  }

  void _openGroup(ExerciseGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupScreen(group: group)),
    ).then((_) => _loadData());
  }

  void _showCreateSheet() {
    if (_isJiggleMode) _exitJiggleMode();
    showModalBottomSheet<({String name, ExerciseType exerciseType, bool isBodyweightOnly})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateExerciseSheet(),
    ).then((result) async {
      if (result == null) return;
      try {
        final rootCount = _exercises.where((e) => e.groupId == null).length +
            _groups.where((g) => g.parentGroupId == null).length;
        final exercise = await DatabaseService.instance.createExercise(
          result.name,
          result.exerciseType,
          result.isBodyweightOnly,
          rootCount,
        );
        if (mounted) {
          setState(() => _exercises.add(exercise));
          _openDetail(exercise);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to create: $e')));
        }
      }
    });
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final oldGroupId = exercise.groupId;
    setState(() => _exercises.remove(exercise));
    await DatabaseService.instance.deleteExercise(exercise.id);
    if (oldGroupId != null) await _checkAndDeleteEmptyGroup(oldGroupId);
  }

  Future<void> _checkAndDeleteEmptyGroup(String groupId) async {
    if (!mounted) return;
    final inGroup = _exercises.where((e) => e.groupId == groupId);
    final subs = _groups.where((g) => g.parentGroupId == groupId);
    if (inGroup.isNotEmpty || subs.isNotEmpty) return;

    final matching = _groups.where((g) => g.id == groupId);
    if (matching.isEmpty) return;
    final group = matching.first;
    final parentId = group.parentGroupId;

    await DatabaseService.instance.deleteGroup(groupId);
    if (!mounted) return;
    setState(() => _groups.removeWhere((g) => g.id == groupId));
    if (parentId != null) await _checkAndDeleteEmptyGroup(parentId);
  }

  Future<void> _reorderItem(_DragData data, int gapIndex) async {
    final items = _rootItems;
    int srcIndex = -1;
    if (data is _ExerciseDrag) {
      srcIndex = items.indexWhere(
          (i) => i is Exercise && i.id == data.exercise.id);
    } else if (data is _GroupDrag) {
      srcIndex = items.indexWhere(
          (i) => i is ExerciseGroup && i.id == data.group.id);
    }
    if (srcIndex == -1) return;

    final newItems = List<Object>.from(items);
    final moved = newItems.removeAt(srcIndex);
    int insertAt = gapIndex > srcIndex ? gapIndex - 1 : gapIndex;
    insertAt = insertAt.clamp(0, newItems.length);
    newItems.insert(insertAt, moved);

    for (int i = 0; i < newItems.length; i++) {
      if (newItems[i] is Exercise) {
        (newItems[i] as Exercise).orderIndex = i;
      } else {
        (newItems[i] as ExerciseGroup).orderIndex = i;
      }
    }
    setState(() {});

    for (int i = 0; i < newItems.length; i++) {
      if (newItems[i] is Exercise) {
        DatabaseService.instance
            .reorderExercise((newItems[i] as Exercise).id, i);
      } else {
        DatabaseService.instance
            .reorderGroup((newItems[i] as ExerciseGroup).id, i);
      }
    }
  }

  Future<void> _createGroupFromExercises(
      Exercise src, Exercise target) async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GroupNameSheet(),
    );
    if (name == null || !mounted) return;

    final orderIndex = math.min(src.orderIndex, target.orderIndex);
    try {
      final group = await DatabaseService.instance.createGroup(
        name,
        parentGroupId: null,
        orderIndex: orderIndex,
      );
      await Future.wait([
        DatabaseService.instance.moveExerciseToGroup(src.id, group.id, 0),
        DatabaseService.instance.moveExerciseToGroup(target.id, group.id, 1),
      ]);
      if (!mounted) return;
      setState(() {
        src.groupId = group.id;
        src.orderIndex = 0;
        target.groupId = group.id;
        target.orderIndex = 1;
        _groups.add(group);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to create group: $e')));
      }
    }
  }

  Future<void> _moveExerciseToGroup(
      Exercise exercise, ExerciseGroup group) async {
    final oldGroupId = exercise.groupId;
    final newIdx =
        _exercises.where((e) => e.groupId == group.id).length;
    await DatabaseService.instance
        .moveExerciseToGroup(exercise.id, group.id, newIdx);
    if (!mounted) return;
    setState(() {
      exercise.groupId = group.id;
      exercise.orderIndex = newIdx;
    });
    if (oldGroupId != null) await _checkAndDeleteEmptyGroup(oldGroupId);
  }

  Future<void> _moveGroupIntoGroup(
      ExerciseGroup src, ExerciseGroup target) async {
    if (src.id == target.id) return;
    final oldParentId = src.parentGroupId;
    final newIdx =
        _groups.where((g) => g.parentGroupId == target.id).length;
    await DatabaseService.instance
        .moveGroupToParent(src.id, target.id, newIdx);
    if (!mounted) return;
    setState(() {
      src.parentGroupId = target.id;
      src.orderIndex = newIdx;
    });
    if (oldParentId != null) await _checkAndDeleteEmptyGroup(oldParentId);
  }

  void _showCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarSheet(exercises: _exercises),
    ).then((_) => _loadData());
  }

  Future<void> _signOut() async => AuthService.instance.signOut();

  Future<void> _deleteAccount() async {
    try {
      await DatabaseService.instance.deleteAllUserData();
      await AuthService.instance.deleteAccount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Delete Account',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone.',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            SizedBox(height: 10),
            Text(
                'All your exercises, workout logs, and account data will be permanently deleted.',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _deleteAccount();
    });
  }

  Widget _buildAvatar() {
    final meta =
        Supabase.instance.client.auth.currentUser?.userMetadata;
    final avatarUrl =
        meta?['avatar_url'] as String? ?? meta?['picture'] as String?;
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
          child: Row(children: [
            Icon(Icons.logout, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(color: Colors.white)),
          ]),
        ),
        PopupMenuItem<String>(
          value: 'delete_account',
          child: Row(children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 18),
            SizedBox(width: 10),
            Text('Delete Account', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
      child: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF6C63FF),
        backgroundImage:
            avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? const Icon(Icons.person, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  // ── Build helpers ──────────────────────────────────────────────

  bool _isDraggingItem(Object item) {
    if (_dragging == null) return false;
    if (_dragging is _ExerciseDrag && item is Exercise) {
      return (_dragging as _ExerciseDrag).exercise.id == item.id;
    }
    if (_dragging is _GroupDrag && item is ExerciseGroup) {
      return (_dragging as _GroupDrag).group.id == item.id;
    }
    return false;
  }

  Widget _buildGap(int gapIndex) {
    if (!_isJiggleMode || _dragging == null) {
      return const SizedBox(height: 12);
    }
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => _reorderItem(details.data, gapIndex),
      builder: (context, candidateData, _) {
        final isHovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: isHovered ? 44 : 20,
          alignment: Alignment.center,
          child: isHovered
              ? Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildExerciseRawCard(Exercise exercise) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _ExerciseCardContent(exercise: exercise),
    );
  }

  Widget _buildItem(Object item, int index) {
    final isDraggingThis = _isDraggingItem(item);
    final screenWidth = MediaQuery.of(context).size.width;

    // 1. Raw card content (no drag/target wrapping)
    Widget rawCard;
    if (item is Exercise) {
      rawCard = _buildExerciseRawCard(item);
    } else {
      final group = item as ExerciseGroup;
      final count = _exercises.where((e) => e.groupId == group.id).length +
          _groups.where((g) => g.parentGroupId == group.id).length;
      rawCard = GroupCard(
        group: group,
        itemCount: count,
        onTap: () => _openGroup(group),
        isJiggleMode: _isJiggleMode,
      );
    }

    // 2. Wrap rawCard in DragTarget for grouping (only when dragging something other than this item)
    Widget displayCard = rawCard;
    if (_isJiggleMode && _dragging != null && !isDraggingThis) {
      displayCard = DragTarget<_DragData>(
        onWillAcceptWithDetails: (details) {
          final src = details.data;
          if (item is Exercise && src is _ExerciseDrag) {
            return src.exercise.id != item.id;
          }
          if (item is ExerciseGroup) {
            if (src is _GroupDrag && src.group.id == item.id) return false;
            return true;
          }
          return false;
        },
        onAcceptWithDetails: (details) {
          final src = details.data;
          if (item is Exercise && src is _ExerciseDrag) {
            _createGroupFromExercises(src.exercise, item);
          } else if (item is ExerciseGroup) {
            if (src is _ExerciseDrag) {
              _moveExerciseToGroup(src.exercise, item);
            } else if (src is _GroupDrag) {
              _moveGroupIntoGroup(src.group, item);
            }
          }
        },
        builder: (context, candidateData, _) {
          final isHovered = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: isHovered
                ? BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFF6C63FF), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: rawCard,
          );
        },
      );
    }

    final feedback = Material(
      color: Colors.transparent,
      child: SizedBox(
        width: screenWidth - 32,
        child: Opacity(opacity: 0.85, child: rawCard),
      ),
    );

    Widget child;
    if (_isJiggleMode) {
      final dragData = item is Exercise
          ? _ExerciseDrag(item)
          : _GroupDrag(item as ExerciseGroup);
      child = GestureDetector(
        onTap: () {}, // absorb tap so it doesn't reach the body's exit-jiggle handler
        child: Draggable<_DragData>(
          data: dragData,
          onDragStarted: () => setState(() => _dragging = dragData),
          onDraggableCanceled: (velocity, offset) => setState(() => _dragging = null),
          onDragEnd: (_) => setState(() => _dragging = null),
          feedback: feedback,
          childWhenDragging: Opacity(opacity: 0.3, child: displayCard),
          child: displayCard,
        ),
      );
    } else {
      // Long-press enters jiggle mode AND starts the drag simultaneously,
      // just like iOS — no need to release and press again.
      final dragData = item is Exercise
          ? _ExerciseDrag(item)
          : _GroupDrag(item as ExerciseGroup);

      final tappableCard = item is Exercise
          ? SwipeToDeleteCard(
              key: ValueKey(item.id),
              onTap: () => _openDetail(item),
              onDeleteConfirmed: () => _deleteExercise(item),
              deleteTitle: 'Delete Exercise',
              deleteMessage: 'Delete "${item.name}" and all its logs?',
              bottomMargin: 0,
              child: _ExerciseCardContent(exercise: item),
            )
          : GestureDetector(
              onTap: () => _openGroup(item as ExerciseGroup),
              child: rawCard,
            );

      child = LongPressDraggable<_DragData>(
        data: dragData,
        onDragStarted: () {
          _enterJiggleMode();
          setState(() => _dragging = dragData);
        },
        onDraggableCanceled: (velocity, offset) => setState(() => _dragging = null),
        onDragEnd: (_) => setState(() => _dragging = null),
        feedback: feedback,
        childWhenDragging: Opacity(opacity: 0.3, child: tappableCard),
        child: tappableCard,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _jiggleController,
        builder: (context, innerChild) {
          if (!_isJiggleMode) return innerChild!;
          final angle =
              math.sin(_jiggleController.value * math.pi * 2 + index * 1.1) *
                  0.018;
          return Transform.rotate(angle: angle, child: innerChild);
        },
        child: child,
      ),
    );
  }

  // ── Screen scaffold ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isJiggleMode ? _exitJiggleMode : null,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text(
            'Progress',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1A1A1A),
          surfaceTintColor: Colors.transparent,
          leading: Opacity(
            opacity: _isJiggleMode ? 0.35 : 1.0,
            child: IconButton(
              icon: const Icon(Icons.calendar_month_outlined,
                  color: Colors.white, size: 24),
              onPressed: _isJiggleMode ? null : _showCalendar,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Opacity(
                opacity: _isJiggleMode ? 0.35 : 1.0,
                child: IgnorePointer(
                  ignoring: _isJiggleMode,
                  child: _buildAvatar(),
                ),
              ),
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
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
              Text('Failed to load exercises',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16)),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _loadData,
                child: const Text('Retry',
                    style:
                        TextStyle(color: Color(0xFF6C63FF), fontSize: 15)),
              ),
            ],
          ),
        ),
      );
    }

    final items = _rootItems;
    return Column(
      children: [
        Expanded(
          child: items.isEmpty
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
                        Text('No exercises yet',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 16)),
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
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  itemCount: 2 * items.length + 1,
                  itemBuilder: (context, index) {
                    if (index.isEven) return _buildGap(index ~/ 2);
                    return _buildItem(items[index ~/ 2], index ~/ 2);
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
          child: Opacity(
            opacity: _isJiggleMode ? 0.4 : 1.0,
            child: GestureDetector(
              onTap: _isJiggleMode ? null : _showCreateSheet,
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
        ),
      ],
    );
  }
}

// ── Private card content widget ────────────────────────────────

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
