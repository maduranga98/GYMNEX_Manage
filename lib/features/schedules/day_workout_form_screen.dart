import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/day_workout.dart';
import 'package:gymnex_manage/core/models/exercise.dart';
import 'package:gymnex_manage/core/services/schedule_service.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';
import 'package:gymnex_manage/widgets/exercise_card.dart';
import 'exercise_form_screen.dart';

class DayWorkoutFormScreen extends StatefulWidget {
  final DayWorkout? dayWorkout;
  final Function(DayWorkout) onSave;
  final bool focusOnExercises;

  const DayWorkoutFormScreen({
    super.key,
    this.dayWorkout,
    required this.onSave,
    this.focusOnExercises = false,
  });

  @override
  State<DayWorkoutFormScreen> createState() => _DayWorkoutFormScreenState();
}

class _DayWorkoutFormScreenState extends State<DayWorkoutFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scheduleService = ScheduleService();
  late TabController _tabController;

  // Controllers
  final _dayNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _warmUpController = TextEditingController();
  final _coolDownController = TextEditingController();
  final _cardioController = TextEditingController();

  // Form data
  String _focusArea = 'Full Body';
  bool _isRestDay = false;
  int _estimatedDuration = 60;
  List<Exercise> _exercises = [];
  List<Exercise> _exerciseLibrary = [];

  final List<String> _focusAreas = [
    'Full Body',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.focusOnExercises ? 1 : 0,
    );

    if (widget.dayWorkout != null) {
      _loadExistingData();
    }

    _loadExerciseLibrary();
  }

  void _loadExistingData() {
    final day = widget.dayWorkout!;
    _dayNameController.text = day.dayName;
    _focusArea = day.focusArea;
    _isRestDay = day.isRestDay;
    _estimatedDuration = day.estimatedDuration;
    _exercises = List.from(day.exercises);
    _notesController.text = day.notes ?? '';
    _warmUpController.text = day.warmUpPlan ?? '';
    _coolDownController.text = day.coolDownPlan ?? '';
    _cardioController.text = day.cardioRoutine ?? '';
  }

  void _loadExerciseLibrary() async {
    _scheduleService.getExerciseLibrary().listen((exercises) {
      if (mounted) {
        setState(() {
          _exerciseLibrary = exercises;
        });
      }
    });
  }

  @override
  void dispose() {
    _dayNameController.dispose();
    _notesController.dispose();
    _warmUpController.dispose();
    _coolDownController.dispose();
    _cardioController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.dayWorkout != null ? 'Edit Workout Day' : 'Add Workout Day',
          style: AppTypography.h3,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveDay,
            child: Text(
              'Save',
              style: AppTypography.button.copyWith(
                color: AppColors.accentColor,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accentColor,
          unselectedLabelColor: AppColors.mutedText,
          indicatorColor: AppColors.accentColor,
          tabs: const [Tab(text: 'Day Info'), Tab(text: 'Exercises')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDayInfoTab(), _buildExercisesTab()],
      ),
    );
  }

  Widget _buildDayInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Name
            CustomTextField(
              controller: _dayNameController,
              hintText: 'Day Name (e.g., Monday, Day 1)',
              prefixIcon: Icon(
                Icons.calendar_today_outlined,
                color: AppColors.mutedText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a day name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Rest Day Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.bedtime_outlined, color: AppColors.mutedText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rest Day',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Mark this as a rest/recovery day',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRestDay,
                    activeColor: AppColors.accentColor,
                    onChanged: (value) => setState(() => _isRestDay = value),
                  ),
                ],
              ),
            ),

            if (!_isRestDay) ...[
              const SizedBox(height: 24),

              // Focus Area
              Text(
                'Focus Area',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inputBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _focusArea,
                    isExpanded: true,
                    style: AppTypography.bodyMedium,
                    dropdownColor: AppColors.cardBackground,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.mutedText,
                    ),
                    items:
                        _focusAreas
                            .map(
                              (area) => DropdownMenuItem(
                                value: area,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getFocusAreaIcon(area),
                                      size: 18,
                                      color: AppColors.mutedText,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(area),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _focusArea = value!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Estimated Duration
              Text(
                'Estimated Duration',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.mutedText),
                    const SizedBox(width: 12),
                    Text('Duration: ', style: AppTypography.bodyMedium),
                    Expanded(
                      child: Slider(
                        value: _estimatedDuration.toDouble(),
                        min: 15,
                        max: 120,
                        divisions: 21,
                        activeColor: AppColors.accentColor,
                        onChanged:
                            (value) => setState(
                              () => _estimatedDuration = value.round(),
                            ),
                      ),
                    ),
                    Text(
                      '${_estimatedDuration}min',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Additional Plans
              Text(
                'Additional Plans',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _warmUpController,
                hintText: 'Warm-up Plan (optional)',
                prefixIcon: Icon(
                  Icons.play_arrow_outlined,
                  color: AppColors.mutedText,
                ),
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _coolDownController,
                hintText: 'Cool-down Plan (optional)',
                prefixIcon: Icon(
                  Icons.stop_outlined,
                  color: AppColors.mutedText,
                ),
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _cardioController,
                hintText: 'Cardio Routine (optional)',
                prefixIcon: Icon(
                  Icons.directions_run_outlined,
                  color: AppColors.mutedText,
                ),
                keyboardType: TextInputType.multiline,
              ),
            ],

            const SizedBox(height: 24),

            // Notes
            CustomTextField(
              controller: _notesController,
              hintText: 'Notes (optional)',
              prefixIcon: Icon(Icons.note_outlined, color: AppColors.mutedText),
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesTab() {
    if (_isRestDay) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime_outlined, size: 64, color: AppColors.mutedText),
            const SizedBox(height: 16),
            Text('Rest Day', style: AppTypography.h3),
            Text(
              'No exercises needed for rest days',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Exercises (${_exercises.length})',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CustomButton(
                text: 'Add Exercise',
                onPressed: _showAddExerciseOptions,
                isOutlined: true,
                height: 40,
              ),
            ],
          ),
        ),

        // Exercises list
        Expanded(
          child:
              _exercises.isEmpty
                  ? _buildEmptyExercisesState()
                  : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _exercises.length,
                    onReorder: _reorderExercises,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return ExerciseCard(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        showOrder: true,
                        onEdit: () => _editExercise(exercise, index),
                        onDelete: () => _deleteExercise(index),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyExercisesState() {
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
                Icons.fitness_center_outlined,
                size: 40,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            Text('No exercises added', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'Add exercises to build your workout',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add First Exercise',
              onPressed: _showAddExerciseOptions,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Exercise', style: AppTypography.h3),
                const SizedBox(height: 20),

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add, color: AppColors.accentColor),
                  ),
                  title: Text(
                    'Create New Exercise',
                    style: AppTypography.bodyMedium,
                  ),
                  subtitle: Text(
                    'Design a custom exercise',
                    style: AppTypography.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _createNewExercise();
                  },
                ),

                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.library_books_outlined,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  title: Text(
                    'From Exercise Library',
                    style: AppTypography.bodyMedium,
                  ),
                  subtitle: Text(
                    'Choose from existing exercises',
                    style: AppTypography.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseLibrary();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _createNewExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExerciseFormScreen(
              onSave: (exercise) {
                setState(() {
                  _exercises.add(
                    exercise.copyWith(
                      id: 'exercise_${_exercises.length + 1}',
                      order: _exercises.length + 1,
                    ),
                  );
                });
              },
            ),
      ),
    );
  }

  void _showExerciseLibrary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Exercise Library', style: AppTypography.h3),
                      const SizedBox(height: 16),

                      // Search bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search exercises...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.mutedText,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.accentColor,
                            ),
                          ),
                        ),
                        onChanged: (query) {
                          // Implement search functionality
                        },
                      ),

                      const SizedBox(height: 16),

                      // Exercise list
                      Expanded(
                        child:
                            _exerciseLibrary.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.library_books_outlined,
                                        size: 48,
                                        color: AppColors.mutedText,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No exercises in library',
                                        style: AppTypography.bodyLarge,
                                      ),
                                      Text(
                                        'Create exercises to build your library',
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  itemCount: _exerciseLibrary.length,
                                  itemBuilder: (context, index) {
                                    final exercise = _exerciseLibrary[index];
                                    return ExerciseListTile(
                                      exercise: exercise,
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _exercises.add(
                                            exercise.copyWith(
                                              id:
                                                  'exercise_${_exercises.length + 1}',
                                              order: _exercises.length + 1,
                                            ),
                                          );
                                        });
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _editExercise(Exercise exercise, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExerciseFormScreen(
              exercise: exercise,
              onSave: (updatedExercise) {
                setState(() {
                  _exercises[index] = updatedExercise;
                });
              },
            ),
      ),
    );
  }

  void _deleteExercise(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text('Delete Exercise', style: AppTypography.h3),
            content: Text(
              'Are you sure you want to remove this exercise?',
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
                    _exercises.removeAt(index);
                    // Reorder remaining exercises
                    for (int i = 0; i < _exercises.length; i++) {
                      _exercises[i] = _exercises[i].copyWith(order: i + 1);
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

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);

      // Update order for all exercises
      for (int i = 0; i < _exercises.length; i++) {
        _exercises[i] = _exercises[i].copyWith(order: i + 1);
      }
    });
  }

  IconData _getFocusAreaIcon(String focusArea) {
    switch (focusArea.toLowerCase()) {
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

  bool _isFormValid() {
    if (_dayNameController.text.isEmpty) return false;
    if (!_isRestDay && _exercises.isEmpty) return false;
    return true;
  }

  void _saveDay() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final dayWorkout = DayWorkout(
      id:
          widget.dayWorkout?.id ??
          'day_${DateTime.now().millisecondsSinceEpoch}',
      dayName: _dayNameController.text,
      focusArea: _isRestDay ? 'Rest' : _focusArea,
      exercises: _isRestDay ? [] : _exercises,
      warmUpPlan:
          _warmUpController.text.isEmpty ? null : _warmUpController.text,
      coolDownPlan:
          _coolDownController.text.isEmpty ? null : _coolDownController.text,
      cardioRoutine:
          _cardioController.text.isEmpty ? null : _cardioController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      dayOrder: widget.dayWorkout?.dayOrder ?? 1,
      isRestDay: _isRestDay,
      estimatedDuration: _isRestDay ? 0 : _estimatedDuration,
    );

    widget.onSave(dayWorkout);
    Navigator.pop(context);
  }
}
