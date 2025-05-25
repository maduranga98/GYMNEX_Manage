import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/schedule.dart';
import '../models/day_workout.dart';
import '../models/exercise.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _schedulesCollection =>
      _firestore.collection('schedules');
  CollectionReference get _templatesCollection =>
      _firestore.collection('schedule_templates');
  CollectionReference get _exerciseLibraryCollection =>
      _firestore.collection('exercise_library');

  // Current user and gym helpers
  String? get _currentUserId => _auth.currentUser?.uid;

  // CRUD Operations for Schedules

  /// Create a new schedule
  Future<String> createSchedule(Schedule schedule, {String? gymId}) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    final scheduleData = schedule.copyWith(
      createdBy: _currentUserId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      gymId: gymId,
    );

    DocumentReference docRef = await _schedulesCollection.add(
      scheduleData.toFirestore(),
    );
    return docRef.id;
  }

  /// Get all schedules for current user/gym
  Stream<List<Schedule>> getSchedules({
    String? gymId,
    bool includeTemplates = false,
  }) {
    Query query = _schedulesCollection.orderBy('updatedAt', descending: true);

    if (gymId != null) {
      query = query.where('gymId', isEqualTo: gymId);
    } else if (_currentUserId != null) {
      query = query.where('createdBy', isEqualTo: _currentUserId);
    }

    if (!includeTemplates) {
      query = query.where('isTemplate', isEqualTo: false);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList(),
    );
  }

  /// Get a single schedule by ID
  Future<Schedule?> getSchedule(String scheduleId) async {
    DocumentSnapshot doc = await _schedulesCollection.doc(scheduleId).get();
    if (doc.exists) {
      return Schedule.fromFirestore(doc);
    }
    return null;
  }

  /// Update an existing schedule
  Future<void> updateSchedule(Schedule schedule) async {
    final updatedSchedule = schedule.copyWith(updatedAt: DateTime.now());
    await _schedulesCollection
        .doc(schedule.id)
        .update(updatedSchedule.toFirestore());
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId) async {
    await _schedulesCollection.doc(scheduleId).delete();
  }

  /// Duplicate a schedule
  Future<String> duplicateSchedule(String scheduleId, {String? newName}) async {
    final originalSchedule = await getSchedule(scheduleId);
    if (originalSchedule == null) throw Exception('Schedule not found');

    final duplicatedSchedule = originalSchedule.copyWith(
      id: '', // Will be set by Firestore
      scheduleName: newName ?? '${originalSchedule.scheduleName} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: _currentUserId!,
      isPublic: false, // Duplicated schedules are private by default
    );

    return await createSchedule(duplicatedSchedule);
  }

  // Template Operations

  /// Get all schedule templates
  Stream<List<Schedule>> getScheduleTemplates({String? category}) {
    Query query = _templatesCollection
        .where('isTemplate', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .orderBy('scheduleName');

    if (category != null) {
      query = query.where('tags', arrayContains: category);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList(),
    );
  }

  /// Create a template from existing schedule
  Future<String> createTemplate(Schedule schedule) async {
    final template = schedule.copyWith(
      id: '', // Will be set by Firestore
      isTemplate: true,
      isPublic: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    DocumentReference docRef = await _templatesCollection.add(
      template.toFirestore(),
    );
    return docRef.id;
  }

  /// Use a template to create a new schedule
  Future<String> createFromTemplate(
    String templateId, {
    String? gymId,
    String? customName,
  }) async {
    final template = await _templatesCollection.doc(templateId).get();
    if (!template.exists) throw Exception('Template not found');

    final templateSchedule = Schedule.fromFirestore(template);
    final newSchedule = templateSchedule.copyWith(
      id: '', // Will be set by Firestore
      scheduleName: customName ?? templateSchedule.scheduleName,
      createdBy: _currentUserId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isTemplate: false,
      isPublic: false,
      gymId: gymId,
    );

    return await createSchedule(newSchedule, gymId: gymId);
  }

  // Exercise Library Operations

  /// Get all exercises from library
  Stream<List<Exercise>> getExerciseLibrary({
    String? muscleGroup,
    String? equipment,
  }) {
    Query query = _exerciseLibraryCollection.orderBy('name');

    // Note: In a real implementation, you'd need composite indexes for multiple where clauses
    // For now, we'll filter in memory after getting the data

    return query.snapshots().map((snapshot) {
      List<Exercise> exercises =
          snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();

      // Apply filters
      if (muscleGroup != null) {
        exercises =
            exercises
                .where(
                  (ex) => ex.equipmentNeeded.any(
                    (eq) =>
                        eq.toLowerCase().contains(muscleGroup.toLowerCase()),
                  ),
                )
                .toList();
      }

      if (equipment != null) {
        exercises =
            exercises
                .where(
                  (ex) => ex.equipmentNeeded.any(
                    (eq) => eq.toLowerCase().contains(equipment.toLowerCase()),
                  ),
                )
                .toList();
      }

      return exercises;
    });
  }

  /// Add exercise to library
  Future<String> addExerciseToLibrary(Exercise exercise) async {
    DocumentReference docRef = await _exerciseLibraryCollection.add(
      exercise.toFirestore(),
    );
    return docRef.id;
  }

  /// Search exercises by name
  Stream<List<Exercise>> searchExercises(String query) {
    return _exerciseLibraryCollection
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList(),
        );
  }

  // Schedule Statistics and Analytics

  /// Get schedule statistics for a gym
  Future<Map<String, dynamic>> getScheduleStats({String? gymId}) async {
    Query query = _schedulesCollection;

    if (gymId != null) {
      query = query.where('gymId', isEqualTo: gymId);
    } else if (_currentUserId != null) {
      query = query.where('createdBy', isEqualTo: _currentUserId);
    }

    final snapshot = await query.get();
    final schedules =
        snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList();

    return {
      'totalSchedules': schedules.length,
      'publicSchedules': schedules.where((s) => s.isPublic).length,
      'templates': schedules.where((s) => s.isTemplate).length,
      'activeSchedules':
          schedules.where((s) => !s.isTemplate && s.isPublic).length,
      'averageDuration':
          schedules.isEmpty
              ? 0
              : schedules.map((s) => s.durationWeeks).reduce((a, b) => a + b) /
                  schedules.length,
      'popularGoals': _getPopularGoals(schedules),
      'popularTargetAudience': _getPopularTargetAudience(schedules),
    };
  }

  /// Get popular goals from schedules
  Map<String, int> _getPopularGoals(List<Schedule> schedules) {
    final goalCounts = <String, int>{};
    for (final schedule in schedules) {
      goalCounts[schedule.goal] = (goalCounts[schedule.goal] ?? 0) + 1;
    }
    return goalCounts;
  }

  /// Get popular target audiences from schedules
  Map<String, int> _getPopularTargetAudience(List<Schedule> schedules) {
    final audienceCounts = <String, int>{};
    for (final schedule in schedules) {
      audienceCounts[schedule.targetAudience] =
          (audienceCounts[schedule.targetAudience] ?? 0) + 1;
    }
    return audienceCounts;
  }

  // Filtering and Searching

  /// Get schedules by goal
  Stream<List<Schedule>> getSchedulesByGoal(String goal, {String? gymId}) {
    Query query = _schedulesCollection.where('goal', isEqualTo: goal);

    if (gymId != null) {
      query = query.where('gymId', isEqualTo: gymId);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList(),
    );
  }

  /// Get schedules by target audience
  Stream<List<Schedule>> getSchedulesByAudience(
    String audience, {
    String? gymId,
  }) {
    Query query = _schedulesCollection.where(
      'targetAudience',
      isEqualTo: audience,
    );

    if (gymId != null) {
      query = query.where('gymId', isEqualTo: gymId);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList(),
    );
  }

  /// Search schedules by name
  Stream<List<Schedule>> searchSchedules(String searchQuery, {String? gymId}) {
    // Firestore doesn't support full-text search, so we'll use a simple approach
    // In production, you might want to use Algolia or similar for better search

    return getSchedules(gymId: gymId).map((schedules) {
      return schedules
          .where(
            (schedule) =>
                schedule.scheduleName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (schedule.description?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                schedule.tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(searchQuery.toLowerCase()),
                ),
          )
          .toList();
    });
  }

  /// Get schedules by tags
  Stream<List<Schedule>> getSchedulesByTag(String tag, {String? gymId}) {
    Query query = _schedulesCollection.where('tags', arrayContains: tag);

    if (gymId != null) {
      query = query.where('gymId', isEqualTo: gymId);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList(),
    );
  }

  // Batch Operations

  /// Bulk update schedules
  Future<void> bulkUpdateSchedules(List<Schedule> schedules) async {
    final batch = _firestore.batch();

    for (final schedule in schedules) {
      final updatedSchedule = schedule.copyWith(updatedAt: DateTime.now());
      batch.update(
        _schedulesCollection.doc(schedule.id),
        updatedSchedule.toFirestore(),
      );
    }

    await batch.commit();
  }

  /// Bulk delete schedules
  Future<void> bulkDeleteSchedules(List<String> scheduleIds) async {
    final batch = _firestore.batch();

    for (final id in scheduleIds) {
      batch.delete(_schedulesCollection.doc(id));
    }

    await batch.commit();
  }

  // Import/Export Functionality

  /// Export schedule to JSON
  Map<String, dynamic> exportSchedule(Schedule schedule) {
    return {
      'schedule': schedule.toFirestore(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Import schedule from JSON
  Future<String> importSchedule(
    Map<String, dynamic> scheduleData, {
    String? gymId,
  }) async {
    final scheduleMap = scheduleData['schedule'] as Map<String, dynamic>;

    // Create new schedule from imported data
    final schedule = Schedule(
      id: '', // Will be set by Firestore
      scheduleName: scheduleMap['scheduleName'] ?? 'Imported Schedule',
      durationWeeks: scheduleMap['durationWeeks'] ?? 4,
      targetAudience: scheduleMap['targetAudience'] ?? 'All',
      goal: scheduleMap['goal'] ?? 'General Fitness',
      genderSpecific: scheduleMap['genderSpecific'] ?? 'All',
      dayWorkouts:
          (scheduleMap['dayWorkouts'] as List<dynamic>?)
              ?.map((e) => DayWorkout.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      description: scheduleMap['description'],
      createdBy: _currentUserId!,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      workoutDaysPerWeek: scheduleMap['workoutDaysPerWeek'] ?? 3,
      tags: List<String>.from(scheduleMap['tags'] ?? []),
      difficulty: scheduleMap['difficulty']?.toDouble(),
      gymId: gymId,
    );

    return await createSchedule(schedule, gymId: gymId);
  }

  // Utility Methods

  /// Get available equipment from gym
  Future<List<String>> getGymEquipment(String gymId) async {
    // This would typically come from the gym's equipment list
    // For now, return common equipment
    return [
      'Dumbbells',
      'Barbell',
      'Kettlebell',
      'Resistance Bands',
      'Cable Machine',
      'Smith Machine',
      'Bench',
      'Pull-up Bar',
      'Treadmill',
      'Stationary Bike',
      'Rowing Machine',
    ];
  }

  /// Validate schedule data
  bool validateSchedule(Schedule schedule) {
    if (schedule.scheduleName.isEmpty) return false;
    if (schedule.durationWeeks <= 0) return false;
    if (schedule.dayWorkouts.isEmpty) return false;

    // Check if all workout days have exercises
    for (final day in schedule.dayWorkouts) {
      if (!day.isRestDay && day.exercises.isEmpty) return false;
    }

    return true;
  }

  /// Get recommended schedules based on user preferences
  Stream<List<Schedule>> getRecommendedSchedules({
    String? goal,
    String? targetAudience,
    int? maxDuration,
    String? gymId,
  }) {
    Query query = _schedulesCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('updatedAt', descending: true);

    return query.snapshots().map((snapshot) {
      List<Schedule> schedules =
          snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList();

      // Apply filters
      if (goal != null) {
        schedules = schedules.where((s) => s.goal == goal).toList();
      }
      if (targetAudience != null) {
        schedules =
            schedules
                .where(
                  (s) =>
                      s.targetAudience == targetAudience ||
                      s.targetAudience == 'All',
                )
                .toList();
      }
      if (maxDuration != null) {
        schedules =
            schedules.where((s) => s.durationWeeks <= maxDuration).toList();
      }
      if (gymId != null) {
        schedules =
            schedules
                .where((s) => s.gymId == gymId || s.gymId == null)
                .toList();
      }

      // Sort by relevance (you can implement more sophisticated sorting)
      schedules.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return schedules.take(10).toList(); // Return top 10
    });
  }
}
