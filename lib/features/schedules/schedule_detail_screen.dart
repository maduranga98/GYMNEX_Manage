import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/schedule.dart';
import 'package:gymnex_manage/core/services/schedule_service.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/day_workout_card.dart';
import 'create_schedule_screen.dart';
import 'exercise_form_screen.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Schedule schedule;

  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen>
    with TickerProviderStateMixin {
  final ScheduleService _scheduleService = ScheduleService();
  late TabController _tabController;
  late Schedule _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = widget.schedule;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [_buildScheduleHeader(), _buildTabSection()],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _schedule.scheduleName,
                  style: AppTypography.h2.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_schedule.durationWeeks} weeks • ${_schedule.targetAudience} • ${_schedule.goal}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white),
          color: AppColors.cardBackground,
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
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
                      Text('Edit Schedule', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
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
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: AppColors.primaryText,
                      ),
                      const SizedBox(width: 12),
                      Text('Share', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 18,
                        color: AppColors.primaryText,
                      ),
                      const SizedBox(width: 12),
                      Text('Export', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
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
        ),
      ],
    );
  }

  Widget _buildScheduleHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (_schedule.description != null &&
              _schedule.description!.isNotEmpty) ...[
            Text(_schedule.description!, style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
          ],

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Duration',
                  '${_schedule.durationWeeks}',
                  'weeks',
                  Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Workout Days',
                  '${_schedule.totalWorkoutDays}',
                  'days',
                  Icons.fitness_center_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Exercises',
                  '${_schedule.totalExercises}',
                  'exercises',
                  Icons.list_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg Duration',
                  '${_schedule.averageWorkoutDuration}',
                  'min/day',
                  Icons.timer_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tags
          if (_schedule.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _schedule.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Difficulty & Settings
          Row(
            children: [
              if (_schedule.difficulty != null) ...[
                _buildDifficultyIndicator(_schedule.difficulty!),
                const SizedBox(width: 16),
              ],
              if (_schedule.isPublic)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, size: 14, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        'Public',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_schedule.isTemplate) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 14,
                        color: AppColors.secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Template',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentColor, size: 20),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.h3.copyWith(color: AppColors.accentColor),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                index < (level / 2).ceil() ? Icons.star : Icons.star_outline,
                size: 12,
                color: color,
              ),
            );
          }),
          const SizedBox(width: 6),
          Text(
            '$level/10',
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.accentColor,
            unselectedLabelColor: AppColors.mutedText,
            indicatorColor: AppColors.accentColor,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Workouts'),
              Tab(text: 'Equipment'),
              Tab(text: 'Overview'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWorkoutsTab(),
              _buildEquipmentTab(),
              _buildOverviewTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _schedule.dayWorkouts.length,
      itemBuilder: (context, index) {
        final dayWorkout = _schedule.dayWorkouts[index];
        return DayWorkoutCard(
          dayWorkout: dayWorkout,
          isExpanded: true,
          showActions: false,
        );
      },
    );
  }

  Widget _buildEquipmentTab() {
    final allEquipment = _schedule.allEquipmentNeeded;

    if (allEquipment.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 16),
            Text('No equipment specified', style: AppTypography.bodyLarge),
            Text(
              'This schedule uses bodyweight exercises',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allEquipment.length,
      itemBuilder: (context, index) {
        final equipment = allEquipment[index];
        final usageCount = _getEquipmentUsageCount(equipment);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getEquipmentIcon(equipment),
                  color: AppColors.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipment,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Used in $usageCount exercises',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Focus Areas
          _buildOverviewSection(
            'Focus Areas',
            Icons.transgender_outlined,
            _schedule.allFocusAreas
                .map(
                  (area) => Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(area, style: AppTypography.bodySmall),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          // Weekly Schedule
          _buildOverviewSection(
            'Weekly Schedule',
            Icons.calendar_view_week_outlined,
            [_buildWeeklyScheduleView()],
          ),

          const SizedBox(height: 24),

          // Schedule Stats
          _buildOverviewSection('Statistics', Icons.analytics_outlined, [
            _buildScheduleStats(),
          ]),

          const SizedBox(height: 24),

          // Created Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Information',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Created', _formatDate(_schedule.createdAt)),
                _buildInfoRow('Last Updated', _formatDate(_schedule.updatedAt)),
                _buildInfoRow('Gender Target', _schedule.genderSpecific),
                if (_schedule.gymId != null)
                  _buildInfoRow('Gym ID', _schedule.gymId!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildWeeklyScheduleView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:
            _schedule.dayWorkouts
                .map(
                  (day) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                day.isRestDay
                                    ? AppColors.mutedText.withValues(alpha: 0.2)
                                    : AppColors.accentColor.withValues(
                                      alpha: 0.2,
                                    ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child:
                                day.isRestDay
                                    ? Icon(
                                      Icons.bedtime_outlined,
                                      size: 16,
                                      color: AppColors.mutedText,
                                    )
                                    : Text(
                                      '${day.dayOrder}',
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentColor,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day.dayName,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                day.isRestDay
                                    ? 'Rest Day'
                                    : '${day.focusArea} • ${day.totalExercises} exercises • ~${day.estimatedDuration} min',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildScheduleStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Sets', '${_schedule.totalSets}'),
              ),
              Expanded(
                child: _buildStatItem(
                  'Workout Days',
                  '${_schedule.totalWorkoutDays}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Rest Days',
                  '${_schedule.totalRestDays}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Equipment Types',
                  '${_schedule.allEquipmentNeeded.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h3.copyWith(color: AppColors.accentColor),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.mutedText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _startWorkout,
      backgroundColor: AppColors.accentColor,
      label: Text('Start Workout', style: AppTypography.button),
      icon: Icon(Icons.play_arrow, color: Colors.white),
    );
  }

  int _getEquipmentUsageCount(String equipment) {
    int count = 0;
    for (final day in _schedule.dayWorkouts) {
      for (final exercise in day.exercises) {
        if (exercise.equipmentNeeded.contains(equipment)) {
          count++;
        }
      }
    }
    return count;
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'dumbbells':
      case 'dumbbell':
        return Icons.fitness_center;
      case 'barbell':
        return Icons.remove;
      case 'kettlebell':
        return Icons.sports_martial_arts;
      case 'treadmill':
        return Icons.directions_run;
      case 'stationary bike':
      case 'bike':
        return Icons.directions_bike;
      case 'pull-up bar':
        return Icons.height;
      case 'bench':
        return Icons.chair_outlined;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editSchedule();
        break;
      case 'duplicate':
        _duplicateSchedule();
        break;
      case 'share':
        _shareSchedule();
        break;
      case 'export':
        _exportSchedule();
        break;
      case 'delete':
        _deleteSchedule();
        break;
    }
  }

  void _editSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateScheduleScreen(
              schedule: _schedule,
              gymId: _schedule.gymId,
            ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh schedule data
        setState(() {});
      }
    });
  }

  void _duplicateSchedule() async {
    try {
      await _scheduleService.duplicateSchedule(_schedule.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule duplicated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to duplicate schedule'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _shareSchedule() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Share Schedule', style: AppTypography.h3),
            content: Text(
              'Share "${_schedule.scheduleName}" with others?',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.button.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Share functionality coming soon')),
                  );
                },
                child: Text(
                  'Share',
                  style: AppTypography.button.copyWith(
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _exportSchedule() async {
    try {
      final exportData = _scheduleService.exportSchedule(_schedule);
      // In a real app, you would save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule exported successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export schedule'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _deleteSchedule() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Delete Schedule', style: AppTypography.h3),
            content: Text(
              'Are you sure you want to delete "${_schedule.scheduleName}"? This action cannot be undone.',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.button.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _scheduleService.deleteSchedule(_schedule.id);
                    Navigator.pop(context); // Go back to list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule deleted successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete schedule'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Text(
                  'Delete',
                  style: AppTypography.button.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _startWorkout() {
    // Navigate to workout session or show start dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Start Workout', style: AppTypography.h3),
            content: Text(
              'Ready to start "${_schedule.scheduleName}"?',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTypography.button.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement workout session start
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Workout session functionality coming soon',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Start',
                  style: AppTypography.button.copyWith(
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
