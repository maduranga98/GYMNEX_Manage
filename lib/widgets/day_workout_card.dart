import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/day_workout.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class DayWorkoutCard extends StatelessWidget {
  final DayWorkout dayWorkout;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddExercise;
  final bool showActions;
  final bool isExpanded;
  final bool isEditable;

  const DayWorkoutCard({
    super.key,
    required this.dayWorkout,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddExercise,
    this.showActions = true,
    this.isExpanded = false,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 12),

              // Focus Area and Stats
              _buildFocusAreaRow(),

              if (isExpanded) ...[
                const SizedBox(height: 16),

                // Exercise List
                _buildExerciseList(),

                // Additional Info
                if (dayWorkout.warmUpPlan != null ||
                    dayWorkout.coolDownPlan != null ||
                    dayWorkout.cardioRoutine != null ||
                    dayWorkout.notes != null)
                  _buildAdditionalInfo(),

                // Add Exercise Button (if editable)
                if (isEditable && !dayWorkout.isRestDay) ...[
                  const SizedBox(height: 12),
                  _buildAddExerciseButton(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Day indicator
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                dayWorkout.isRestDay
                    ? AppColors.mutedText.withValues(alpha: 0.2)
                    : AppColors.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child:
                dayWorkout.isRestDay
                    ? Icon(
                      Icons.bedtime_outlined,
                      color: AppColors.mutedText,
                      size: 20,
                    )
                    : Text(
                      '${dayWorkout.dayOrder}',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentColor,
                      ),
                    ),
          ),
        ),

        const SizedBox(width: 12),

        // Day info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayWorkout.dayName,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dayWorkout.isRestDay
                    ? 'Rest Day'
                    : '${dayWorkout.estimatedDuration} min',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),

        // Actions
        if (showActions) _buildActionMenu(),

        // Expand indicator
        if (onTap != null)
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.mutedText,
          ),
      ],
    );
  }

  Widget _buildFocusAreaRow() {
    if (dayWorkout.isRestDay) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.mutedText.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.self_improvement, size: 16, color: AppColors.mutedText),
            const SizedBox(width: 8),
            Text(
              'Rest and Recovery',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Focus area chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getFocusAreaColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getFocusAreaIcon(), size: 14, color: _getFocusAreaColor()),
              const SizedBox(width: 6),
              Text(
                dayWorkout.focusArea,
                style: AppTypography.bodySmall.copyWith(
                  color: _getFocusAreaColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Stats
        if (dayWorkout.exercises.isNotEmpty) ...[
          _buildStatChip(
            Icons.fitness_center_outlined,
            '${dayWorkout.totalExercises}',
            'exercises',
          ),
          const SizedBox(width: 8),
          _buildStatChip(Icons.repeat, '${dayWorkout.totalSets}', 'sets'),
        ],
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryText),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (dayWorkout.isRestDay || dayWorkout.exercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.divider.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              dayWorkout.isRestDay
                  ? Icons.bedtime_outlined
                  : Icons.add_circle_outline,
              color: AppColors.mutedText,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              dayWorkout.isRestDay
                  ? 'Rest day - no exercises planned'
                  : 'No exercises added yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercises (${dayWorkout.exercises.length})',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...dayWorkout.exercises
            .map(
              (exercise) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accentColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exercise.sets} sets × ${exercise.reps} reps • ${exercise.restTime}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (exercise.weight != null && exercise.weight!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          exercise.weight!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Additional Information',
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        if (dayWorkout.warmUpPlan != null) ...[
          _buildInfoSection(
            Icons.play_arrow_outlined,
            'Warm-up',
            dayWorkout.warmUpPlan!,
            AppColors.success,
          ),
          const SizedBox(height: 8),
        ],

        if (dayWorkout.coolDownPlan != null) ...[
          _buildInfoSection(
            Icons.stop_outlined,
            'Cool-down',
            dayWorkout.coolDownPlan!,
            AppColors.secondaryColor,
          ),
          const SizedBox(height: 8),
        ],

        if (dayWorkout.cardioRoutine != null) ...[
          _buildInfoSection(
            Icons.directions_run_outlined,
            'Cardio',
            dayWorkout.cardioRoutine!,
            AppColors.warning,
          ),
          const SizedBox(height: 8),
        ],

        if (dayWorkout.notes != null) ...[
          _buildInfoSection(
            Icons.note_outlined,
            'Notes',
            dayWorkout.notes!,
            AppColors.primaryText,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return InkWell(
      onTap: onAddExercise,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accentColor.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Exercise',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: AppColors.mutedText),
      color: AppColors.cardBackground,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
          case 'add_exercise':
            onAddExercise?.call();
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
                      size: 18,
                      color: AppColors.primaryText,
                    ),
                    const SizedBox(width: 12),
                    Text('Edit Day', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            if (onAddExercise != null && !dayWorkout.isRestDay)
              PopupMenuItem(
                value: 'add_exercise',
                child: Row(
                  children: [
                    Icon(
                      Icons.add_outlined,
                      size: 18,
                      color: AppColors.primaryText,
                    ),
                    const SizedBox(width: 12),
                    Text('Add Exercise', style: AppTypography.bodyMedium),
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
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Day',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
    );
  }

  Color _getFocusAreaColor() {
    switch (dayWorkout.focusArea.toLowerCase()) {
      case 'chest':
        return Colors.red;
      case 'back':
        return Colors.blue;
      case 'legs':
        return Colors.green;
      case 'shoulders':
        return Colors.orange;
      case 'arms':
        return Colors.purple;
      case 'core':
        return Colors.teal;
      case 'cardio':
        return Colors.pink;
      case 'full body':
        return AppColors.accentColor;
      default:
        return AppColors.primaryText;
    }
  }

  IconData _getFocusAreaIcon() {
    switch (dayWorkout.focusArea.toLowerCase()) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.back_hand;
      case 'legs':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.expand_less;
      case 'arms':
        return Icons.sports_martial_arts;
      case 'core':
        return Icons.center_focus_strong;
      case 'cardio':
        return Icons.favorite;
      case 'full body':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }
}

// Compact version for day selection
class DayWorkoutTile extends StatelessWidget {
  final DayWorkout dayWorkout;
  final VoidCallback? onTap;
  final bool isSelected;

  const DayWorkoutTile({
    super.key,
    required this.dayWorkout,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                dayWorkout.isRestDay
                    ? AppColors.mutedText.withValues(alpha: 0.2)
                    : AppColors.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child:
                dayWorkout.isRestDay
                    ? Icon(
                      Icons.bedtime_outlined,
                      color: AppColors.mutedText,
                      size: 20,
                    )
                    : Text(
                      '${dayWorkout.dayOrder}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentColor,
                      ),
                    ),
          ),
        ),
        title: Text(
          dayWorkout.dayName,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          dayWorkout.isRestDay
              ? 'Rest Day'
              : '${dayWorkout.focusArea} • ${dayWorkout.totalExercises} exercises',
          style: AppTypography.bodySmall.copyWith(color: AppColors.mutedText),
        ),
        trailing:
            isSelected
                ? Icon(Icons.check_circle, color: AppColors.accentColor)
                : Icon(Icons.chevron_right, color: AppColors.mutedText),
      ),
    );
  }
}
