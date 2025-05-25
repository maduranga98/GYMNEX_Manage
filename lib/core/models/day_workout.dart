import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';

class DayWorkout {
  final String id;
  final String dayName; // e.g., "Monday", "Day 1", "Week 1 - Day 1"
  final String
  focusArea; // e.g., "Chest", "Back", "Legs", "Full Body", "Cardio", "Rest"
  final List<Exercise> exercises;
  final String? warmUpPlan; // Optional warm-up instructions
  final String? coolDownPlan; // Optional cool-down instructions
  final String? cardioRoutine; // Optional cardio after weights
  final String? notes; // Additional notes for the day
  final int dayOrder; // Order in the schedule (1, 2, 3...)
  final bool isRestDay; // Whether this is a rest day
  final int estimatedDuration; // Estimated workout duration in minutes

  DayWorkout({
    required this.id,
    required this.dayName,
    required this.focusArea,
    this.exercises = const [],
    this.warmUpPlan,
    this.coolDownPlan,
    this.cardioRoutine,
    this.notes,
    this.dayOrder = 1,
    this.isRestDay = false,
    this.estimatedDuration = 60,
  });

  factory DayWorkout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return DayWorkout(
      id: doc.id,
      dayName: data['dayName'] ?? '',
      focusArea: data['focusArea'] ?? '',
      exercises:
          (data['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      warmUpPlan: data['warmUpPlan'],
      coolDownPlan: data['coolDownPlan'],
      cardioRoutine: data['cardioRoutine'],
      notes: data['notes'],
      dayOrder: data['dayOrder'] ?? 1,
      isRestDay: data['isRestDay'] ?? false,
      estimatedDuration: data['estimatedDuration'] ?? 60,
    );
  }

  factory DayWorkout.fromMap(Map<String, dynamic> data) {
    return DayWorkout(
      id: data['id'] ?? '',
      dayName: data['dayName'] ?? '',
      focusArea: data['focusArea'] ?? '',
      exercises:
          (data['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      warmUpPlan: data['warmUpPlan'],
      coolDownPlan: data['coolDownPlan'],
      cardioRoutine: data['cardioRoutine'],
      notes: data['notes'],
      dayOrder: data['dayOrder'] ?? 1,
      isRestDay: data['isRestDay'] ?? false,
      estimatedDuration: data['estimatedDuration'] ?? 60,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayName': dayName,
      'focusArea': focusArea,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'warmUpPlan': warmUpPlan,
      'coolDownPlan': coolDownPlan,
      'cardioRoutine': cardioRoutine,
      'notes': notes,
      'dayOrder': dayOrder,
      'isRestDay': isRestDay,
      'estimatedDuration': estimatedDuration,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayName': dayName,
      'focusArea': focusArea,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'warmUpPlan': warmUpPlan,
      'coolDownPlan': coolDownPlan,
      'cardioRoutine': cardioRoutine,
      'notes': notes,
      'dayOrder': dayOrder,
      'isRestDay': isRestDay,
      'estimatedDuration': estimatedDuration,
    };
  }

  DayWorkout copyWith({
    String? id,
    String? dayName,
    String? focusArea,
    List<Exercise>? exercises,
    String? warmUpPlan,
    String? coolDownPlan,
    String? cardioRoutine,
    String? notes,
    int? dayOrder,
    bool? isRestDay,
    int? estimatedDuration,
  }) {
    return DayWorkout(
      id: id ?? this.id,
      dayName: dayName ?? this.dayName,
      focusArea: focusArea ?? this.focusArea,
      exercises: exercises ?? this.exercises,
      warmUpPlan: warmUpPlan ?? this.warmUpPlan,
      coolDownPlan: coolDownPlan ?? this.coolDownPlan,
      cardioRoutine: cardioRoutine ?? this.cardioRoutine,
      notes: notes ?? this.notes,
      dayOrder: dayOrder ?? this.dayOrder,
      isRestDay: isRestDay ?? this.isRestDay,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    );
  }

  // Helper methods
  int get totalExercises => exercises.length;

  int get totalSets =>
      exercises.fold(0, (sum, exercise) => sum + exercise.sets);

  List<String> get allEquipmentNeeded {
    final Set<String> equipment = {};
    for (final exercise in exercises) {
      equipment.addAll(exercise.equipmentNeeded);
    }
    return equipment.toList();
  }

  bool get hasExercises => exercises.isNotEmpty;

  @override
  String toString() {
    return 'DayWorkout(id: $id, dayName: $dayName, focusArea: $focusArea, exercises: ${exercises.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayWorkout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for common focus areas
enum FocusArea {
  chest('Chest'),
  back('Back'),
  legs('Legs'),
  shoulders('Shoulders'),
  arms('Arms'),
  core('Core'),
  full_body('Full Body'),
  cardio('Cardio'),
  hiit('HIIT'),
  stretching('Stretching'),
  rest('Rest Day');

  const FocusArea(this.displayName);
  final String displayName;
}

// Enum for day types
enum DayType {
  workout('Workout'),
  rest('Rest'),
  active_recovery('Active Recovery'),
  cardio_only('Cardio Only');

  const DayType(this.displayName);
  final String displayName;
}
