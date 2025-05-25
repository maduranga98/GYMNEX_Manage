import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymnex_manage/core/models/schedule.dart';
import 'package:gymnex_manage/core/services/schedule_service.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/schedule_card.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'create_schedule_screen.dart';
import 'schedule_detail_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  final String? gymId;

  const ScheduleListScreen({super.key, this.gymId});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen>
    with TickerProviderStateMixin {
  final ScheduleService _scheduleService = ScheduleService();
  late TabController _tabController;

  String _searchQuery = '';
  String _selectedGoal = 'All';
  String _selectedAudience = 'All';
  bool _showTemplates = false;

  final List<String> _goals = [
    'All',
    'Strength',
    'Muscle Gain',
    'Weight Loss',
    'Endurance',
    'General Fitness',
  ];

  final List<String> _audiences = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        title: Text('Workout Schedules', style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.primaryText),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryText),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accentColor,
          unselectedLabelColor: AppColors.mutedText,
          indicatorColor: AppColors.accentColor,
          tabs: const [Tab(text: 'My Schedules'), Tab(text: 'Templates')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMySchedulesTab(), _buildTemplatesTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewSchedule,
        backgroundColor: AppColors.accentColor,
        label: Text('Create Schedule', style: AppTypography.button),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMySchedulesTab() {
    return StreamBuilder<List<Schedule>>(
      stream: _getFilteredSchedules(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load schedules');
        }

        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return _buildEmptyState(
            'No schedules found',
            'Create your first workout schedule to get started',
            Icons.calendar_today_outlined,
            _createNewSchedule,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshSchedules,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ScheduleCard(
                schedule: schedule,
                onTap: () => _viewScheduleDetail(schedule),
                onEdit: () => _editSchedule(schedule),
                onDelete: () => _deleteSchedule(schedule),
                onDuplicate: () => _duplicateSchedule(schedule),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTemplatesTab() {
    return StreamBuilder<List<Schedule>>(
      stream: _scheduleService.getScheduleTemplates(
        category: _selectedGoal != 'All' ? _selectedGoal : null,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState('Failed to load templates');
        }

        final templates = snapshot.data ?? [];

        if (templates.isEmpty) {
          return _buildEmptyState(
            'No templates available',
            'Templates will appear here when available',
            Icons.library_books_outlined,
            null,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshSchedules,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return ScheduleCard(
                schedule: template,
                isTemplate: true,
                onTap: () => _viewScheduleDetail(template),
                onDuplicate: () => _useTemplate(template),
                showActions: false,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onAction,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Schedule',
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, style: AppTypography.bodyLarge),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: () => setState(() {}),
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Schedule>> _getFilteredSchedules() {
    if (_searchQuery.isNotEmpty) {
      return _scheduleService.searchSchedules(
        _searchQuery,
        gymId: widget.gymId,
      );
    }

    if (_selectedGoal != 'All') {
      return _scheduleService.getSchedulesByGoal(
        _selectedGoal,
        gymId: widget.gymId,
      );
    }

    if (_selectedAudience != 'All') {
      return _scheduleService.getSchedulesByAudience(
        _selectedAudience,
        gymId: widget.gymId,
      );
    }

    return _scheduleService.getSchedules(gymId: widget.gymId);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Search Schedules', style: AppTypography.h3),
            content: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Enter schedule name...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedText,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.mutedText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentColor),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => _searchQuery = '');
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear',
                  style: AppTypography.button.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Search',
                  style: AppTypography.button.copyWith(
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Filter Schedules', style: AppTypography.h3),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGoal,
                  style: AppTypography.bodyMedium,
                  dropdownColor: AppColors.cardBackground,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      _goals
                          .map(
                            (goal) => DropdownMenuItem(
                              value: goal,
                              child: Text(goal),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _selectedGoal = value!),
                ),
                const SizedBox(height: 16),
                Text(
                  'Target Audience',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedAudience,
                  style: AppTypography.bodyMedium,
                  dropdownColor: AppColors.cardBackground,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      _audiences
                          .map(
                            (audience) => DropdownMenuItem(
                              value: audience,
                              child: Text(audience),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => _selectedAudience = value!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedGoal = 'All';
                    _selectedAudience = 'All';
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear',
                  style: AppTypography.button.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Apply',
                  style: AppTypography.button.copyWith(
                    color: AppColors.accentColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _refreshSchedules() async {
    setState(() {});
  }

  void _createNewSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateScheduleScreen(gymId: widget.gymId),
      ),
    );
  }

  void _viewScheduleDetail(Schedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleDetailScreen(schedule: schedule),
      ),
    );
  }

  void _editSchedule(Schedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                CreateScheduleScreen(schedule: schedule, gymId: widget.gymId),
      ),
    );
  }

  void _duplicateSchedule(Schedule schedule) async {
    try {
      await _scheduleService.duplicateSchedule(schedule.id);
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

  void _deleteSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Delete Schedule', style: AppTypography.h3),
            content: Text(
              'Are you sure you want to delete "${schedule.scheduleName}"? This action cannot be undone.',
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
                    await _scheduleService.deleteSchedule(schedule.id);
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

  void _useTemplate(Schedule template) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Use Template', style: AppTypography.h3),
            content: Text(
              'Create a new schedule based on "${template.scheduleName}"?',
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
                    await _scheduleService.createFromTemplate(
                      template.id,
                      gymId: widget.gymId,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Schedule created from template'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to create schedule from template',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Text(
                  'Create',
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
