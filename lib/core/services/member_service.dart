import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _membersCollection =>
      _firestore.collection('members');

  // Get stream of all members
  Stream<List<Member>> getMembers() {
    return _membersCollection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList(),
        );
  }

  // Get a single member
  Future<Member?> getMember(String id) async {
    DocumentSnapshot doc = await _membersCollection.doc(id).get();
    if (doc.exists) {
      return Member.fromFirestore(doc);
    }
    return null;
  }

  // Add a new member
  Future<String> addMember(Member member) async {
    DocumentReference docRef = await _membersCollection.add(
      member.toFirestore(),
    );
    return docRef.id;
  }

  // Update an existing member
  Future<void> updateMember(Member member) async {
    return await _membersCollection.doc(member.id).update(member.toFirestore());
  }

  // Delete a member
  Future<void> deleteMember(String id) async {
    return await _membersCollection.doc(id).delete();
  }

  // Get members by status
  Stream<List<Member>> getMembersByStatus(String status) {
    return _membersCollection
        .where('status', isEqualTo: status)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList(),
        );
  }

  // Search members by name
  Stream<List<Member>> searchMembers(String query) {
    // Firestore doesn't support direct SQL-like queries, so we'll fetch all and filter
    return _membersCollection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Member.fromFirestore(doc))
                  .where(
                    (member) =>
                        member.name.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ||
                        member.email.toLowerCase().contains(
                          query.toLowerCase(),
                        ),
                  )
                  .toList(),
        );
  }

  // Update member status
  Future<void> updateMemberStatus(String id, String status) async {
    return await _membersCollection.doc(id).update({'status': status});
  }

  // Update membership plan
  Future<void> updateMembershipPlan(
    String id,
    String plan,
    DateTime expiryDate,
  ) async {
    return await _membersCollection.doc(id).update({
      'membershipPlan': plan,
      'membershipExpiryDate': Timestamp.fromDate(expiryDate),
      'status': 'active',
    });
  }

  // Add attendance record
  Future<DocumentReference<Map<String, dynamic>>> addAttendanceRecord(
    String memberId,
    DateTime date,
  ) async {
    return await _membersCollection.doc(memberId).collection('attendance').add({
      'date': Timestamp.fromDate(date),
      'present': true,
    });
  }

  // Add performance record
  Future<DocumentReference<Map<String, dynamic>>> addPerformanceRecord(
    String memberId,
    DateTime date,
    Map<String, dynamic> metrics,
  ) async {
    return await _membersCollection.doc(memberId).collection('performance').add(
      {'date': Timestamp.fromDate(date), 'metrics': metrics},
    );
  }

  // Get attendance records
  Stream<QuerySnapshot> getAttendanceRecords(String memberId) {
    return _membersCollection
        .doc(memberId)
        .collection('attendance')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get performance records
  Stream<QuerySnapshot> getPerformanceRecords(String memberId) {
    return _membersCollection
        .doc(memberId)
        .collection('performance')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
