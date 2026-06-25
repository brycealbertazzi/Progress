import 'package:flutter/material.dart';
import '../models/exercise_group.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.itemCount,
    required this.onTap,
    this.isJiggleMode = false,
    this.isDropTarget = false,
  });

  final ExerciseGroup group;
  final int itemCount;
  final VoidCallback onTap;
  final bool isJiggleMode;
  final bool isDropTarget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isJiggleMode ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDropTarget
                ? const Color(0xFF6C63FF)
                : const Color(0xFF6C63FF).withValues(alpha: 0.5),
            width: isDropTarget ? 2.5 : 1.8,
          ),
        ),
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
                child: const Icon(
                  Icons.folder_rounded,
                  color: Color(0xFF6C63FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$itemCount',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF6C63FF)),
            ],
          ),
        ),
      ),
    );
  }
}
