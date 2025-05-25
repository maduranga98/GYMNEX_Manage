import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_workout.dart';

class Schedule {
  final String id;
  final String scheduleName;
  final int durationWeeks; // Duration in weeks
  final String targetAudience; // Beginner, Intermediate, Advanced
  final String goal; // Strength, Muscle Gain, Weight Loss, Endurance
  final String genderSpecific; // Male, Female, All
  final List<DayWorkout> dayWorkouts;
  final String? description; // Optional description
  final String? imageUrl; // Optional cover image
  final String createdBy; // Coach/Trainer ID
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic; // Whether visible to members
  final bool isTemplate; // Whether this is a template
  final int workoutDaysPerWeek; // Number of workout days per week
  final List<String> tags; // Tags for categorization
  final double? difficulty; // Difficulty rating (1-10)
  final String? gymId; // Associated gym ID

  Schedule({
    required this.id,
    required this.scheduleName,
    required this.durationWeeks,
    required this.targetAudience,
    required this.goal,
    required this.genderSpecific,
    this.dayWorkouts = const [],
    this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.isTemplate = false,
    this.workoutDaysPerWeek = 3,
    this.tags = const [],
    this.difficulty,
    this.gymId,
  });

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Schedule(
      id: doc.id,
      scheduleName: data['scheduleName'] ?? '',
      durationWeeks: data['durationWeeks'] ?? 4,
      targetAudience: data['targetAudience'] ?? 'All',
      goal: data['goal'] ?? 'General Fitness',
      genderSpecific: data['genderSpecific'] ?? 'All',
      dayWorkouts:
          (data['dayWorkouts'] as List<dynamic>?)
              ?.map((e) => DayWorkout.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: data['isPublic'] ?? false,
      isTemplate: data['isTemplate'] ?? false,
      workoutDaysPerWeek: data['workoutDaysPerWeek'] ?? 3,
      tags: List<String>.from(data['tags'] ?? []),
      difficulty: data['difficulty']?.toDouble(),
      gymId: data['gymId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'scheduleName': scheduleName,
      'durationWeeks': durationWeeks,
      'targetAudience': targetAudience,
      'goal': goal,
      'genderSpecific': genderSpecific,
      'dayWorkouts': dayWorkouts.map((e) => e.toMap()).toList(),
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'isTemplate': isTemplate,
      'workoutDaysPerWeek': workoutDaysPerWeek,
      'tags': tags,
      'difficulty': difficulty,
      'gymId': gymId,
    };
  }

  Schedule copyWith({
    String? id,
    String? scheduleName,
    int? durationWeeks,
    String? targetAudience,
    String? goal,
    String? genderSpecific,
    List<DayWorkout>? dayWorkouts,
    String? description,
    String? imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    bool? isTemplate,
    int? workoutDaysPerWeek,
    List<String>? tags,
    double? difficulty,
    String? gymId,
  }) {
    return Schedule(
      id: id ?? this.id,
      scheduleName: scheduleName ?? this.scheduleName,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      targetAudience: targetAudience ?? this.targetAudience,
      goal: goal ?? this.goal,
      genderSpecific: genderSpecific ?? this.genderSpecific,
      dayWorkouts: dayWorkouts ?? this.dayWorkouts,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      isTemplate: isTemplate ?? this.isTemplate,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      gymId: gymId ?? this.gymId,
    );
  }

  // Helper methods
  int get totalDays => dayWorkouts.length;

  int get totalWorkoutDays => dayWorkouts.where((day) => !day.isRestDay).length;

  int get totalRestDays => dayWorkouts.where((day) => day.isRestDay).length;

  int get totalExercises =>
      dayWorkouts.fold(0, (sum, day) => sum + day.totalExercises);

  int get totalSets => dayWorkouts.fold(0, (sum, day) => sum + day.totalSets);

  List<String> get allEquipmentNeeded {
    final Set<String> equipment = {};
    for (final day in dayWorkouts) {
      equipment.addAll(day.allEquipmentNeeded);
    }
    return equipment.toList();
  }

  List<String> get allFocusAreas {
    return dayWorkouts
        .where((day) => !day.isRestDay)
        .map((day) => day.focusArea)
        .toSet()
        .toList();
  }

  int get averageWorkoutDuration {
    final workoutDays = dayWorkouts.where((day) => !day.isRestDay);
    if (workoutDays.isEmpty) return 0;

    final totalDuration = workoutDays.fold(
      0,
      (sum, day) => sum + day.estimatedDuration,
    );
    return (totalDuration / workoutDays.length).round();
  }

  bool get isComplete =>
      dayWorkouts.isNotEmpty &&
      dayWorkouts.every((day) => day.isRestDay || day.hasExercises);

  @override
  String toString() {
    return 'Schedule(id: $id, name: $scheduleName, duration: ${durationWeeks}w, days: ${dayWorkouts.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enums for Schedule properties
enum TargetAudience {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  all('All Levels');

  const TargetAudience(this.displayName);
  final String displayName;
}

enum FitnessGoal {
  strength('Strength'),
  muscle_gain('Muscle Gain'),
  weight_loss('Weight Loss'),
  endurance('Endurance'),
  general_fitness('General Fitness'),
  athletic_performance('Athletic Performance'),
  rehabilitation('Rehabilitation');

  const FitnessGoal(this.displayName);
  final String displayName;
}

enum GenderTarget {
  male('Male'),
  female('Female'),
  all('All');

  const GenderTarget(this.displayName);
  final String displayName;
}

// Schedule status for tracking
enum ScheduleStatus {
  draft('Draft'),
  active('Active'),
  completed('Completed'),
  archived('Archived');

  const ScheduleStatus(this.displayName);
  final String displayName;
}
