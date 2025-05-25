import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id;
  final String name;
  final int sets;
  final String reps; // Can be "10-12" or "10" or "Max"
  final String restTime; // e.g., "60 sec", "2 min"
  final String? weight; // Optional weight or % of max
  final String? videoUrl; // Optional video instruction link
  final String? instructionNote; // Coach's instruction
  final List<String> equipmentNeeded; // List of equipment
  final String? tips; // Coach's tips/notes
  final int order; // Order in the workout

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restTime,
    this.weight,
    this.videoUrl,
    this.instructionNote,
    this.equipmentNeeded = const [],
    this.tips,
    this.order = 0,
  });

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Exercise(
      id: doc.id,
      name: data['name'] ?? '',
      sets: data['sets'] ?? 1,
      reps: data['reps'] ?? '1',
      restTime: data['restTime'] ?? '60 sec',
      weight: data['weight'],
      videoUrl: data['videoUrl'],
      instructionNote: data['instructionNote'],
      equipmentNeeded: List<String>.from(data['equipmentNeeded'] ?? []),
      tips: data['tips'],
      order: data['order'] ?? 0,
    );
  }

  factory Exercise.fromMap(Map<String, dynamic> data) {
    return Exercise(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      sets: data['sets'] ?? 1,
      reps: data['reps'] ?? '1',
      restTime: data['restTime'] ?? '60 sec',
      weight: data['weight'],
      videoUrl: data['videoUrl'],
      instructionNote: data['instructionNote'],
      equipmentNeeded: List<String>.from(data['equipmentNeeded'] ?? []),
      tips: data['tips'],
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'restTime': restTime,
      'weight': weight,
      'videoUrl': videoUrl,
      'instructionNote': instructionNote,
      'equipmentNeeded': equipmentNeeded,
      'tips': tips,
      'order': order,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'restTime': restTime,
      'weight': weight,
      'videoUrl': videoUrl,
      'instructionNote': instructionNote,
      'equipmentNeeded': equipmentNeeded,
      'tips': tips,
      'order': order,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    int? sets,
    String? reps,
    String? restTime,
    String? weight,
    String? videoUrl,
    String? instructionNote,
    List<String>? equipmentNeeded,
    String? tips,
    int? order,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
      weight: weight ?? this.weight,
      videoUrl: videoUrl ?? this.videoUrl,
      instructionNote: instructionNote ?? this.instructionNote,
      equipmentNeeded: equipmentNeeded ?? this.equipmentNeeded,
      tips: tips ?? this.tips,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, sets: $sets, reps: $reps)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for common equipment types
enum EquipmentType {
  dumbbells('Dumbbells'),
  barbell('Barbell'),
  kettlebell('Kettlebell'),
  bodyweight('Bodyweight'),
  resistance_bands('Resistance Bands'),
  cable_machine('Cable Machine'),
  smith_machine('Smith Machine'),
  bench('Bench'),
  pull_up_bar('Pull-up Bar'),
  treadmill('Treadmill'),
  stationary_bike('Stationary Bike'),
  rowing_machine('Rowing Machine'),
  other('Other');

  const EquipmentType(this.displayName);
  final String displayName;
}

// Enum for common muscle groups
enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  biceps('Biceps'),
  triceps('Triceps'),
  legs('Legs'),
  glutes('Glutes'),
  core('Core'),
  cardio('Cardio'),
  full_body('Full Body');

  const MuscleGroup(this.displayName);
  final String displayName;
}
