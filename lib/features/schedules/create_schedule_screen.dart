import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/schedule.dart';
import 'package:gymnex_manage/core/models/day_workout.dart';
import 'package:gymnex_manage/core/services/schedule_service.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';
import 'package:gymnex_manage/widgets/day_workout_card.dart';
import 'day_workout_form_screen.dart';

class CreateScheduleScreen extends StatefulWidget {
  final Schedule? schedule; // For editing existing schedule
  final String? gymId;

  const CreateScheduleScreen({super.key, this.schedule, this.gymId});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scheduleService = ScheduleService();
  final _pageController = PageController();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  // Form data
  int _currentStep = 0;
  int _durationWeeks = 4;
  String _targetAudience = 'All';
  String _goal = 'General Fitness';
  String _genderSpecific = 'All';
  int _workoutDaysPerWeek = 3;
  double _difficulty = 5.0;
  bool _isPublic = false;
  bool _isTemplate = false;
  List<DayWorkout> _dayWorkouts = [];
  List<String> _tags = [];
  bool _isSaving = false;

  final List<String> _audiences = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  final List<String> _goals = [
    'General Fitness',
    'Strength',
    'Muscle Gain',
    'Weight Loss',
    'Endurance',
    'Athletic Performance',
  ];
  final List<String> _genders = ['All', 'Male', 'Female'];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _loadExistingSchedule();
    } else {
      _initializeEmptySchedule();
    }
  }

  void _loadExistingSchedule() {
    final schedule = widget.schedule!;
    _nameController.text = schedule.scheduleName;
    _descriptionController.text = schedule.description ?? '';
    _durationWeeks = schedule.durationWeeks;
    _targetAudience = schedule.targetAudience;
    _goal = schedule.goal;
    _genderSpecific = schedule.genderSpecific;
    _workoutDaysPerWeek = schedule.workoutDaysPerWeek;
    _difficulty = schedule.difficulty ?? 5.0;
    _isPublic = schedule.isPublic;
    _isTemplate = schedule.isTemplate;
    _dayWorkouts = List.from(schedule.dayWorkouts);
    _tags = List.from(schedule.tags);
    _tagsController.text = _tags.join(', ');
  }

  void _initializeEmptySchedule() {
    // Generate default day workouts
    _generateDefaultDayWorkouts();
  }

  void _generateDefaultDayWorkouts() {
    _dayWorkouts.clear();
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (int i = 0; i < _workoutDaysPerWeek; i++) {
      _dayWorkouts.add(
        DayWorkout(
          id: 'day_${i + 1}',
          dayName: days[i],
          focusArea: 'Full Body',
          dayOrder: i + 1,
          exercises: [],
        ),
      );
    }

    // Add rest days
    for (int i = _workoutDaysPerWeek; i < 7; i++) {
      _dayWorkouts.add(
        DayWorkout(
          id: 'rest_${i + 1}',
          dayName: days[i],
          focusArea: 'Rest',
          dayOrder: i + 1,
          isRestDay: true,
          exercises: [],
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.schedule != null ? 'Edit Schedule' : 'Create Schedule',
          style: AppTypography.h3,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _saveSchedule,
              child: Text(
                'Save',
                style: AppTypography.button.copyWith(
                  color: AppColors.accentColor,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildBasicInfoStep(),
                _buildDayWorkoutsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Basic Info', Icons.info_outline),
          Expanded(child: _buildProgressLine(0)),
          _buildStepIndicator(1, 'Workouts', Icons.fitness_center_outlined),
          Expanded(child: _buildProgressLine(1)),
          _buildStepIndicator(2, 'Review', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? AppColors.success
                    : isActive
                    ? AppColors.accentColor
                    : AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.accentColor : AppColors.divider,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : AppColors.mutedText,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isActive ? AppColors.accentColor : AppColors.mutedText,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = _currentStep > step;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success : AppColors.divider,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: AppTypography.h3),
            const SizedBox(height: 16),

            // Schedule Name
            CustomTextField(
              controller: _nameController,
              hintText: 'Schedule Name',
              prefixIcon: Icon(
                Icons.fitness_center_outlined,
                color: AppColors.mutedText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a schedule name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            CustomTextField(
              controller: _descriptionController,
              hintText: 'Description (optional)',
              prefixIcon: Icon(
                Icons.description_outlined,
                color: AppColors.mutedText,
              ),
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 24),

            // Duration
            Text(
              'Duration',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: 12),
                  Text('Duration: ', style: AppTypography.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _durationWeeks.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      activeColor: AppColors.accentColor,
                      onChanged:
                          (value) =>
                              setState(() => _durationWeeks = value.round()),
                    ),
                  ),
                  Text(
                    '${_durationWeeks}w',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Target Audience
            _buildDropdownField(
              'Target Audience',
              _targetAudience,
              _audiences,
              Icons.people_outline,
              (value) => setState(() => _targetAudience = value!),
            ),

            const SizedBox(height: 16),

            // Fitness Goal
            _buildDropdownField(
              'Fitness Goal',
              _goal,
              _goals,
              Icons.flag_outlined,
              (value) => setState(() => _goal = value!),
            ),

            const SizedBox(height: 16),

            // Gender Specific
            _buildDropdownField(
              'Gender Target',
              _genderSpecific,
              _genders,
              Icons.person_outline,
              (value) => setState(() => _genderSpecific = value!),
            ),

            const SizedBox(height: 16),

            // Workout Days Per Week
            Text(
              'Workout Days Per Week',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: 12),
                  Text('Days: ', style: AppTypography.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _workoutDaysPerWeek.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      activeColor: AppColors.accentColor,
                      onChanged: (value) {
                        setState(() {
                          _workoutDaysPerWeek = value.round();
                          _generateDefaultDayWorkouts();
                        });
                      },
                    ),
                  ),
                  Text(
                    '$_workoutDaysPerWeek',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Difficulty
            Text(
              'Difficulty Level',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up_outlined, color: AppColors.mutedText),
                  const SizedBox(width: 12),
                  Text('Level: ', style: AppTypography.bodyMedium),
                  Expanded(
                    child: Slider(
                      value: _difficulty,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.accentColor,
                      onChanged: (value) => setState(() => _difficulty = value),
                    ),
                  ),
                  Text(
                    '${_difficulty.round()}/10',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tags
            CustomTextField(
              controller: _tagsController,
              hintText: 'Tags (comma separated)',
              prefixIcon: Icon(Icons.tag_outlined, color: AppColors.mutedText),
              onChanged: (value) {
                _tags =
                    value
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList();
              },
            ),

            const SizedBox(height: 24),

            // Settings
            Text(
              'Settings',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Make Public', style: AppTypography.bodyMedium),
                    subtitle: Text(
                      'Allow other members to view this schedule',
                      style: AppTypography.bodySmall,
                    ),
                    value: _isPublic,
                    activeColor: AppColors.accentColor,
                    onChanged: (value) => setState(() => _isPublic = value),
                  ),
                  Divider(color: AppColors.divider, height: 1),
                  SwitchListTile(
                    title: Text(
                      'Save as Template',
                      style: AppTypography.bodyMedium,
                    ),
                    subtitle: Text(
                      'Make this schedule available as a template',
                      style: AppTypography.bodySmall,
                    ),
                    value: _isTemplate,
                    activeColor: AppColors.accentColor,
                    onChanged: (value) => setState(() => _isTemplate = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayWorkoutsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day Workouts', style: AppTypography.h3),
                    Text(
                      'Plan your weekly workout schedule',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Add Day',
                onPressed: _addNewDay,
                isOutlined: true,
                height: 40,
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _dayWorkouts.isEmpty
                  ? _buildEmptyDaysState()
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dayWorkouts.length,
                    itemBuilder: (context, index) {
                      final dayWorkout = _dayWorkouts[index];
                      return DayWorkoutCard(
                        dayWorkout: dayWorkout,
                        isEditable: true,
                        onTap: () => _editDayWorkout(dayWorkout, index),
                        onEdit: () => _editDayWorkout(dayWorkout, index),
                        onDelete: () => _deleteDayWorkout(index),
                        onAddExercise:
                            () => _addExercisesToDay(dayWorkout, index),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyDaysState() {
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
              child: Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            Text('No workout days planned', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'Add workout days to create your schedule',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add First Day',
              onPressed: _addNewDay,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Save', style: AppTypography.h3),
          const SizedBox(height: 16),

          // Schedule Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule Summary',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Name', _nameController.text),
                _buildSummaryRow('Duration', '${_durationWeeks} weeks'),
                _buildSummaryRow('Target Audience', _targetAudience),
                _buildSummaryRow('Goal', _goal),
                _buildSummaryRow(
                  'Workout Days',
                  '$_workoutDaysPerWeek per week',
                ),
                _buildSummaryRow('Total Days', '${_dayWorkouts.length}'),
                _buildSummaryRow(
                  'Workout Days',
                  '${_dayWorkouts.where((d) => !d.isRestDay).length}',
                ),
                _buildSummaryRow(
                  'Rest Days',
                  '${_dayWorkouts.where((d) => d.isRestDay).length}',
                ),
                _buildSummaryRow(
                  'Total Exercises',
                  '${_dayWorkouts.fold<int>(0, (sum, day) => sum + day.totalExercises)}',
                ),
                _buildSummaryRow('Difficulty', '${_difficulty.round()}/10'),
                if (_tags.isNotEmpty)
                  _buildSummaryRow('Tags', _tags.join(', ')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Day Workouts Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout Days',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._dayWorkouts
                    .map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color:
                                    day.isRestDay
                                        ? AppColors.mutedText.withValues(
                                          alpha: 0.2,
                                        )
                                        : AppColors.accentColor.withValues(
                                          alpha: 0.2,
                                        ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child:
                                    day.isRestDay
                                        ? Icon(
                                          Icons.bedtime_outlined,
                                          size: 14,
                                          color: AppColors.mutedText,
                                        )
                                        : Text(
                                          '${day.dayOrder}',
                                          style: AppTypography.caption.copyWith(
                                            fontWeight: FontWeight.bold,
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
                                        : '${day.focusArea} • ${day.totalExercises} exercises',
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Validation Messages
          if (!_isScheduleValid()) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_outlined, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please complete all workout days with exercises before saving.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: AppTypography.bodyMedium,
              dropdownColor: AppColors.cardBackground,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.mutedText),
              items:
                  items
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: AppColors.mutedText),
                              const SizedBox(width: 12),
                              Text(item),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Previous',
                onPressed: _previousStep,
                isOutlined: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: _currentStep == 2 ? 'Save Schedule' : 'Next',
              onPressed: _currentStep == 2 ? _saveSchedule : _nextStep,
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addNewDay() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DayWorkoutFormScreen(
              onSave: (dayWorkout) {
                setState(() {
                  _dayWorkouts.add(
                    dayWorkout.copyWith(
                      id: 'day_${_dayWorkouts.length + 1}',
                      dayOrder: _dayWorkouts.length + 1,
                    ),
                  );
                });
              },
            ),
      ),
    );
  }

  void _editDayWorkout(DayWorkout dayWorkout, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DayWorkoutFormScreen(
              dayWorkout: dayWorkout,
              onSave: (updatedDayWorkout) {
                setState(() {
                  _dayWorkouts[index] = updatedDayWorkout;
                });
              },
            ),
      ),
    );
  }

  void _deleteDayWorkout(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Delete Day', style: AppTypography.h3),
            content: Text(
              'Are you sure you want to delete this workout day?',
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
                  setState(() {
                    _dayWorkouts.removeAt(index);
                    // Reorder remaining days
                    for (int i = 0; i < _dayWorkouts.length; i++) {
                      _dayWorkouts[i] = _dayWorkouts[i].copyWith(
                        dayOrder: i + 1,
                      );
                    }
                  });
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

  void _addExercisesToDay(DayWorkout dayWorkout, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DayWorkoutFormScreen(
              dayWorkout: dayWorkout,
              focusOnExercises: true,
              onSave: (updatedDayWorkout) {
                setState(() {
                  _dayWorkouts[index] = updatedDayWorkout;
                });
              },
            ),
      ),
    );
  }

  bool _isScheduleValid() {
    if (_nameController.text.isEmpty) return false;
    if (_dayWorkouts.isEmpty) return false;

    // Check if all workout days have exercises
    for (final day in _dayWorkouts) {
      if (!day.isRestDay && day.exercises.isEmpty) return false;
    }

    return true;
  }

  Future<void> _saveSchedule() async {
    if (!_isScheduleValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all required fields and add exercises to workout days',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final schedule = Schedule(
        id: widget.schedule?.id ?? '',
        scheduleName: _nameController.text,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
        durationWeeks: _durationWeeks,
        targetAudience: _targetAudience,
        goal: _goal,
        genderSpecific: _genderSpecific,
        dayWorkouts: _dayWorkouts,
        createdBy: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: _isPublic,
        isTemplate: _isTemplate,
        workoutDaysPerWeek: _workoutDaysPerWeek,
        tags: _tags,
        difficulty: _difficulty,
        gymId: widget.gymId,
      );

      if (widget.schedule != null) {
        await _scheduleService.updateSchedule(schedule);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        await _scheduleService.createSchedule(schedule, gymId: widget.gymId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save schedule: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
