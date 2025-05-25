import 'package:flutter/material.dart';
import 'package:gymnex_manage/core/models/exercise.dart';
import 'package:gymnex_manage/core/utils/app_colors.dart';
import 'package:gymnex_manage/core/utils/app_typography.dart';
import 'package:gymnex_manage/widgets/custom_button.dart';
import 'package:gymnex_manage/widgets/custom_text_field.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;
  final Function(Exercise) onSave;

  const ExerciseFormScreen({super.key, this.exercise, required this.onSave});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _instructionController = TextEditingController();
  final _tipsController = TextEditingController();

  // Form data
  String _restTime = '60 sec';
  List<String> _selectedEquipment = [];

  final List<String> _restTimeOptions = [
    '30 sec',
    '45 sec',
    '60 sec',
    '90 sec',
    '2 min',
    '3 min',
    '5 min',
  ];

  final List<String> _equipmentOptions = [
    'Dumbbells',
    'Barbell',
    'Kettlebell',
    'Resistance Bands',
    'Cable Machine',
    'Smith Machine',
    'Bench',
    'Pull-up Bar',
    'Bodyweight',
    'Treadmill',
    'Stationary Bike',
    'Rowing Machine',
    'Medicine Ball',
    'Bosu Ball',
    'TRX',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _loadExistingData();
    } else {
      _setDefaults();
    }
  }

  void _loadExistingData() {
    final exercise = widget.exercise!;
    _nameController.text = exercise.name;
    _setsController.text = exercise.sets.toString();
    _repsController.text = exercise.reps;
    _restTime = exercise.restTime;
    _weightController.text = exercise.weight ?? '';
    _videoUrlController.text = exercise.videoUrl ?? '';
    _instructionController.text = exercise.instructionNote ?? '';
    _tipsController.text = exercise.tips ?? '';
    _selectedEquipment = List.from(exercise.equipmentNeeded);
  }

  void _setDefaults() {
    _setsController.text = '3';
    _repsController.text = '10';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _videoUrlController.dispose();
    _instructionController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.exercise != null ? 'Edit Exercise' : 'Add Exercise',
          style: AppTypography.h3,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveExercise,
            child: Text(
              'Save',
              style: AppTypography.button.copyWith(
                color: AppColors.accentColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Name
              Text('Exercise Details', style: AppTypography.h3),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                hintText: 'Exercise Name',
                prefixIcon: Icon(
                  Icons.fitness_center_outlined,
                  color: AppColors.mutedText,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter exercise name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Sets and Reps
              Text(
                'Sets & Reps',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _setsController,
                      hintText: 'Sets',
                      prefixIcon: Icon(
                        Icons.repeat,
                        color: AppColors.mutedText,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _repsController,
                      hintText: 'Reps (e.g., 10, 8-12)',
                      prefixIcon: Icon(
                        Icons.fitness_center,
                        color: AppColors.mutedText,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Rest Time
              Text(
                'Rest Time',
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
                    value: _restTime,
                    isExpanded: true,
                    style: AppTypography.bodyMedium,
                    dropdownColor: AppColors.cardBackground,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.mutedText,
                    ),
                    items:
                        _restTimeOptions
                            .map(
                              (time) => DropdownMenuItem(
                                value: time,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 18,
                                      color: AppColors.mutedText,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(time),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _restTime = value!),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Weight (Optional)
              CustomTextField(
                controller: _weightController,
                hintText: 'Weight (optional, e.g., 50kg, 80% 1RM)',
                prefixIcon: Icon(
                  Icons.monitor_weight_outlined,
                  color: AppColors.mutedText,
                ),
              ),

              const SizedBox(height: 24),

              // Equipment Needed
              Text(
                'Equipment Needed',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _equipmentOptions.map((equipment) {
                            final isSelected = _selectedEquipment.contains(
                              equipment,
                            );
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedEquipment.remove(equipment);
                                  } else {
                                    _selectedEquipment.add(equipment);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.accentColor.withValues(
                                            alpha: 0.1,
                                          )
                                          : AppColors.scaffoldBackground,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.accentColor
                                            : AppColors.divider,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  equipment,
                                  style: AppTypography.bodySmall.copyWith(
                                    color:
                                        isSelected
                                            ? AppColors.accentColor
                                            : AppColors.primaryText,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    if (_selectedEquipment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Selected: ${_selectedEquipment.join(', ')}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Video/Instructions
              Text(
                'Instructions & Media',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _videoUrlController,
                hintText: 'Video URL (optional)',
                prefixIcon: Icon(
                  Icons.play_circle_outline,
                  color: AppColors.mutedText,
                ),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _instructionController,
                hintText: 'Exercise Instructions (optional)',
                prefixIcon: Icon(
                  Icons.info_outline,
                  color: AppColors.mutedText,
                ),
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _tipsController,
                hintText: 'Coach Tips & Notes (optional)',
                prefixIcon: Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.mutedText,
                ),
                keyboardType: TextInputType.multiline,
              ),

              const SizedBox(height: 32),

              // Preview Section
              Text(
                'Preview',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'Exercise Name'
                          : _nameController.text,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPreviewChip(
                          Icons.repeat,
                          '${_setsController.text.isEmpty ? '0' : _setsController.text} sets',
                        ),
                        const SizedBox(width: 8),
                        _buildPreviewChip(
                          Icons.fitness_center,
                          '${_repsController.text.isEmpty ? '0' : _repsController.text} reps',
                        ),
                        const SizedBox(width: 8),
                        _buildPreviewChip(Icons.timer_outlined, _restTime),
                      ],
                    ),
                    if (_weightController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
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
                              _weightController.text,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_selectedEquipment.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            _selectedEquipment
                                .take(3)
                                .map(
                                  (equipment) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.divider.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      equipment,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text:
                    widget.exercise != null
                        ? 'Update Exercise'
                        : 'Add Exercise',
                onPressed: _saveExercise,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.accentColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.accentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _saveExercise() {
    if (!_formKey.currentState!.validate()) return;

    final exercise = Exercise(
      id:
          widget.exercise?.id ??
          'exercise_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      sets: int.parse(_setsController.text),
      reps: _repsController.text,
      restTime: _restTime,
      weight: _weightController.text.isEmpty ? null : _weightController.text,
      videoUrl:
          _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
      instructionNote:
          _instructionController.text.isEmpty
              ? null
              : _instructionController.text,
      equipmentNeeded: _selectedEquipment,
      tips: _tipsController.text.isEmpty ? null : _tipsController.text,
      order: widget.exercise?.order ?? 1,
    );

    widget.onSave(exercise);
    Navigator.pop(context);
  }
}
