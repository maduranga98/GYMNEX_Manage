import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/exercise.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReorder;
  final bool showActions;
  final bool showOrder;
  final bool isSelected;
  final bool isDraggable;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onReorder,
    this.showActions = true,
    this.showOrder = false,
    this.isSelected = false,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.accentColor.withValues(alpha: 0.1)
                : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(color: AppColors.accentColor, width: 1)
                : Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  width: 1,
                ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  if (showOrder)
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${exercise.order}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDraggable)
                    Icon(
                      Icons.drag_handle,
                      color: AppColors.mutedText,
                      size: 20,
                    ),
                  if (showActions && !isDraggable) _buildActionMenu(),
                ],
              ),

              const SizedBox(height: 8),

              // Exercise Details
              Row(
                children: [
                  _buildDetailChip(
                    Icons.repeat,
                    '${exercise.sets} sets',
                    AppColors.primaryText,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.fitness_center,
                    '${exercise.reps} reps',
                    AppColors.accentColor,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.timer_outlined,
                    exercise.restTime,
                    AppColors.secondaryColor,
                  ),
                ],
              ),

              // Weight (if available)
              if (exercise.weight != null && exercise.weight!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.weight!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Equipment (if available)
              if (exercise.equipmentNeeded.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      exercise.equipmentNeeded.take(3).map((equipment) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.divider.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            equipment,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],

              // Tips/Notes (if available)
              if (exercise.tips != null && exercise.tips!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          exercise.tips!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Video/Instruction indicator
              if (exercise.videoUrl != null ||
                  exercise.instructionNote != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (exercise.videoUrl != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 12,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Video',
                              style: AppTypography.caption.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (exercise.videoUrl != null &&
                        exercise.instructionNote != null)
                      const SizedBox(width: 6),
                    if (exercise.instructionNote != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Instructions',
                              style: AppTypography.caption.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Wrap with Draggable if needed
    if (isDraggable) {
      return Draggable<Exercise>(
        data: exercise,
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 300,
            child: Opacity(opacity: 0.8, child: cardContent),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: cardContent),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.mutedText, size: 18),
      color: AppColors.cardBackground,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
          case 'reorder':
            onReorder?.call();
            break;
        }
      },
      itemBuilder:
          (context) => [
            if (onEdit != null)
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primaryText,
                    ),
                    const SizedBox(width: 8),
                    Text('Edit', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            if (onReorder != null)
              PopupMenuItem(
                value: 'reorder',
                child: Row(
                  children: [
                    Icon(Icons.reorder, size: 16, color: AppColors.primaryText),
                    const SizedBox(width: 8),
                    Text('Reorder', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            if (onDelete != null)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
    );
  }
}

// Compact version for selection lists
class ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const ExerciseListTile({
    super.key,
    required this.exercise,
    this.onTap,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.accentColor.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            color: AppColors.accentColor,
            size: 20,
          ),
        ),
        title: Text(
          exercise.name,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${exercise.sets} sets • ${exercise.reps} reps • ${exercise.restTime}',
          style: AppTypography.bodySmall.copyWith(color: AppColors.mutedText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            trailing ??
            (isSelected
                ? Icon(Icons.check_circle, color: AppColors.accentColor)
                : null),
      ),
    );
  }
}
