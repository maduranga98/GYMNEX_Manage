import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String type;
  final DateTime joinDate;
  final String status; // active, inactive, expired
  final String photoUrl;
  final String membershipPlan;
  final DateTime? membershipExpiryDate;
  final Map<String, dynamic> additionalInfo;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.joinDate,
    required this.status,
    this.photoUrl = '',
    required this.membershipPlan,
    this.membershipExpiryDate,
    this.additionalInfo = const {},
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Member(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      type: data['type'] ?? '',
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'inactive',
      photoUrl: data['photoUrl'] ?? '',
      membershipPlan: data['membershipPlan'] ?? '',
      membershipExpiryDate:
          data['membershipExpiryDate'] != null
              ? (data['membershipExpiryDate'] as Timestamp).toDate()
              : null,
      additionalInfo: data['additionalInfo'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'joinDate': Timestamp.fromDate(joinDate),
      'status': status,
      'photoUrl': photoUrl,
      'membershipPlan': membershipPlan,
      'membershipExpiryDate':
          membershipExpiryDate != null
              ? Timestamp.fromDate(membershipExpiryDate!)
              : null,
      'additionalInfo': additionalInfo,
    };
  }

  Member copyWith({
    String? name,
    String? email,
    String? phone,
    String? type,
    DateTime? joinDate,
    String? status,
    String? photoUrl,
    String? membershipPlan,
    DateTime? membershipExpiryDate,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Member(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      membershipPlan: membershipPlan ?? this.membershipPlan,
      membershipExpiryDate: membershipExpiryDate ?? this.membershipExpiryDate,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
