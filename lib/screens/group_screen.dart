import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/exercise_group.dart';
import '../models/exercise_type.dart';
import '../services/database_service.dart';
import '../widgets/bodyweight_badge.dart';
import '../widgets/create_exercise_sheet.dart';
import '../widgets/group_card.dart';
import '../widgets/group_name_sheet.dart';
import '../widgets/swipe_to_delete_card.dart';
import 'exercise_detail_screen.dart';

sealed class _DragData {}

class _ExerciseDrag extends _DragData {
  final Exercise exercise;
  _ExerciseDrag(this.exercise);
}

class _GroupDrag extends _DragData {
  final ExerciseGroup group;
  _GroupDrag(this.group);
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.group});

  final ExerciseGroup group;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with SingleTickerProviderStateMixin {
  List<Exercise> _exercises = [];
  List<ExerciseGroup> _groups = [];
  bool _isLoading = true;
  String? _error;
  bool _isJiggleMode = false;
  _DragData? _dragging;
  late final AnimationController _jiggleController;
  late String _groupName;

  @override
  void initState() {
    super.initState();
    _groupName = widget.group.name;
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

  // Items directly in this group, sorted by orderIndex
  List<Object> get _groupItems {
    final items = <Object>[
      ..._exercises.where((e) => e.groupId == widget.group.id),
      ..._groups.where((g) => g.parentGroupId == widget.group.id),
    ];
    items.sort((a, b) {
      final ai = a is Exercise ? a.orderIndex : (a as ExerciseGroup).orderIndex;
      final bi = b is Exercise ? b.orderIndex : (b as ExerciseGroup).orderIndex;
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
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(exercise: exercise),
      ),
    ).then((_) => _loadData());
  }

  void _openSubGroup(ExerciseGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupScreen(group: group)),
    ).then((_) => _loadData());
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _groupName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Rename Group',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: const Color(0xFF6C63FF),
          decoration: InputDecoration(
            hintText: 'Group name',
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
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final trimmed = controller.text.trim();
              Navigator.pop(ctx);
              if (trimmed.isEmpty || trimmed == _groupName) return;
              setState(() {
                _groupName = trimmed;
                widget.group.name = trimmed;
              });
              await DatabaseService.instance.renameGroup(
                widget.group.id,
                trimmed,
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    if (_isJiggleMode) _exitJiggleMode();
    showModalBottomSheet<
          ({String name, ExerciseType exerciseType, bool isBodyweightOnly})
        >(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const CreateExerciseSheet(),
        )
        .then((result) async {
          if (result == null) return;
          try {
            final idx =
                _exercises.where((e) => e.groupId == widget.group.id).length +
                _groups.where((g) => g.parentGroupId == widget.group.id).length;
            final exercise = await DatabaseService.instance.createExercise(
              result.name,
              result.exerciseType,
              result.isBodyweightOnly,
              idx,
              groupId: widget.group.id,
            );
            if (mounted) {
              setState(() => _exercises.add(exercise));
              _openDetail(exercise);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Failed to create: $e')));
            }
          }
        });
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    setState(() => _exercises.remove(exercise));
    await DatabaseService.instance.deleteExercise(exercise.id);
    await _checkAndDeleteEmptyGroup(widget.group.id);
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

    if (groupId == widget.group.id) {
      // This group itself was deleted → pop back
      if (mounted) Navigator.pop(context);
      return;
    }
    if (parentId != null) await _checkAndDeleteEmptyGroup(parentId);
  }

  Future<void> _moveItemToRoot(_DragData data) async {
    if (data is _ExerciseDrag) {
      final exercise = data.exercise;
      final rootCount =
          _exercises.where((e) => e.groupId == null).length +
          _groups.where((g) => g.parentGroupId == null).length;
      await DatabaseService.instance.moveExerciseToGroup(
        exercise.id,
        null,
        rootCount,
      );
      setState(() {
        exercise.groupId = null;
        exercise.orderIndex = rootCount;
      });
    } else if (data is _GroupDrag) {
      final group = data.group;
      final rootCount = _groups.where((g) => g.parentGroupId == null).length;
      await DatabaseService.instance.moveGroupToParent(
        group.id,
        null,
        rootCount,
      );
      setState(() {
        group.parentGroupId = null;
        group.orderIndex = rootCount;
      });
    }
    await _checkAndDeleteEmptyGroup(widget.group.id);
  }

  Future<void> _reorderItem(_DragData data, int gapIndex) async {
    final items = _groupItems;
    int srcIndex = -1;
    if (data is _ExerciseDrag) {
      srcIndex = items.indexWhere(
        (i) => i is Exercise && i.id == data.exercise.id,
      );
    } else if (data is _GroupDrag) {
      srcIndex = items.indexWhere(
        (i) => i is ExerciseGroup && i.id == data.group.id,
      );
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
        DatabaseService.instance.reorderExercise(
          (newItems[i] as Exercise).id,
          i,
        );
      } else {
        DatabaseService.instance.reorderGroup(
          (newItems[i] as ExerciseGroup).id,
          i,
        );
      }
    }
  }

  Future<void> _createGroupFromExercises(Exercise src, Exercise target) async {
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
        parentGroupId: widget.group.id,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create group: $e')));
      }
    }
  }

  Future<void> _moveExerciseToGroup(
    Exercise exercise,
    ExerciseGroup group,
  ) async {
    final oldGroupId = exercise.groupId;
    final newIdx = _exercises.where((e) => e.groupId == group.id).length;
    await DatabaseService.instance.moveExerciseToGroup(
      exercise.id,
      group.id,
      newIdx,
    );
    if (!mounted) return;
    setState(() {
      exercise.groupId = group.id;
      exercise.orderIndex = newIdx;
    });
    if (oldGroupId != null && oldGroupId != group.id) {
      await _checkAndDeleteEmptyGroup(oldGroupId);
    }
  }

  Future<void> _moveGroupIntoGroup(
    ExerciseGroup src,
    ExerciseGroup target,
  ) async {
    if (src.id == target.id) return;
    final oldParentId = src.parentGroupId;
    final newIdx = _groups.where((g) => g.parentGroupId == target.id).length;
    await DatabaseService.instance.moveGroupToParent(src.id, target.id, newIdx);
    if (!mounted) return;
    setState(() {
      src.parentGroupId = target.id;
      src.orderIndex = newIdx;
    });
    if (oldParentId != null && oldParentId != target.id) {
      await _checkAndDeleteEmptyGroup(oldParentId);
    }
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

    Widget rawCard;
    if (item is Exercise) {
      rawCard = _buildExerciseRawCard(item);
    } else {
      final group = item as ExerciseGroup;
      final count =
          _exercises.where((e) => e.groupId == group.id).length +
          _groups.where((g) => g.parentGroupId == group.id).length;
      rawCard = GroupCard(
        group: group,
        itemCount: count,
        onTap: () => _openSubGroup(group),
        isJiggleMode: _isJiggleMode,
      );
    }

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
                      color: const Color(0xFF6C63FF),
                      width: 2,
                    ),
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
        onTap: () {},
        child: Draggable<_DragData>(
          data: dragData,
          onDragStarted: () => setState(() => _dragging = dragData),
          onDraggableCanceled: (velocity, offset) =>
              setState(() => _dragging = null),
          onDragEnd: (_) => setState(() => _dragging = null),
          feedback: feedback,
          childWhenDragging: Opacity(opacity: 0.3, child: displayCard),
          child: displayCard,
        ),
      );
    } else {
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
              onTap: () => _openSubGroup(item as ExerciseGroup),
              child: rawCard,
            );

      child = LongPressDraggable<_DragData>(
        data: dragData,
        onDragStarted: () {
          _enterJiggleMode();
          setState(() => _dragging = dragData);
        },
        onDraggableCanceled: (velocity, offset) =>
            setState(() => _dragging = null),
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

  Widget _buildMoveOutZone() {
    if (!_isJiggleMode || _dragging == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: DragTarget<_DragData>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (details) => _moveItemToRoot(details.data),
        builder: (context, candidateData, _) {
          final isHovered = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF6C63FF).withValues(alpha: 0.35),
                width: isHovered ? 2 : 1,
              ),
            ),
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
                  child: const Icon(
                    Icons.subdirectory_arrow_left_rounded,
                    color: Color(0xFF6C63FF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Drag here to move out',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
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
          backgroundColor: const Color(0xFF1A1A1A),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: GestureDetector(
            onTap: _isJiggleMode ? null : _showRenameDialog,
            child: Text(
              _groupName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          leading: Opacity(
            opacity: _isJiggleMode ? 0.35 : 1.0,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _isJiggleMode ? null : () => Navigator.pop(context),
            ),
          ),
          actions: [
            Opacity(
              opacity: _isJiggleMode ? 0.35 : 1.0,
              child: IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF6C63FF),
                  size: 22,
                ),
                onPressed: _isJiggleMode ? null : _showRenameDialog,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: _buildBody(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),
      );
    }

    final items = _groupItems;
    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No exercises in this group yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 15,
                      ),
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
        _buildMoveOutZone(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            4,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
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
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
