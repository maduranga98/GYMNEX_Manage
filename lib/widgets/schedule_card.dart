import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/schedule.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final bool showActions;
  final bool isTemplate;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.showActions = true,
    this.isTemplate = false,
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
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.scheduleName,
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildInfoChip(
                              schedule.targetAudience,
                              Icons.person_outline,
                              AppColors.accentColor,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              schedule.goal,
                              Icons.flag_outlined,
                              AppColors.secondaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showActions) _buildActionMenu(),
                ],
              ),

              const SizedBox(height: 12),

              // Description (if available)
              if (schedule.description != null &&
                  schedule.description!.isNotEmpty) ...[
                Text(
                  schedule.description!,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Statistics Row
              Row(
                children: [
                  _buildStatItem(
                    Icons.calendar_today_outlined,
                    '${schedule.durationWeeks}w',
                    'Duration',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.fitness_center_outlined,
                    '${schedule.totalWorkoutDays}',
                    'Workout Days',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.timeline_outlined,
                    '${schedule.totalExercises}',
                    'Exercises',
                  ),
                  const Spacer(),
                  if (schedule.difficulty != null)
                    _buildDifficultyIndicator(schedule.difficulty!),
                ],
              ),

              const SizedBox(height: 12),

              // Tags
              if (schedule.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      schedule.tags
                          .take(3)
                          .map((tag) => _buildTag(tag))
                          .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Footer
              Row(
                children: [
                  Icon(
                    isTemplate
                        ? Icons.library_books_outlined
                        : Icons.schedule_outlined,
                    size: 14,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isTemplate ? 'Template' : _formatDate(schedule.updatedAt),
                    style: AppTypography.caption,
                  ),
                  const Spacer(),
                  if (schedule.isPublic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.public,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Public',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryText),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildDifficultyIndicator(double difficulty) {
    final level = difficulty.round();
    final color =
        level <= 3
            ? AppColors.success
            : level <= 7
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            return Icon(
              index < (level / 2).ceil() ? Icons.circle : Icons.circle_outlined,
              size: 8,
              color: color,
            );
          }),
          const SizedBox(width: 4),
          Text(
            '$level/10',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: AppTypography.caption.copyWith(color: AppColors.secondaryText),
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
          case 'duplicate':
            onDuplicate?.call();
            break;
          case 'delete':
            onDelete?.call();
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
                    Text('Edit', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            if (onDuplicate != null)
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: AppColors.primaryText,
                    ),
                    const SizedBox(width: 12),
                    Text('Duplicate', style: AppTypography.bodyMedium),
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
                      'Delete',
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    if (difference < 30) return '${(difference / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
