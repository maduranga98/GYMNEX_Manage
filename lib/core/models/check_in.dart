import 'package:intl/intl.dart';

class CheckIn {
  final String id;
  final String memberId;
  final String memberName;
  final String memberImage;
  final DateTime checkInTime;
  final String membershipType;

  CheckIn({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberImage,
    required this.checkInTime,
    required this.membershipType,
  });

  String get formattedTime => DateFormat('h:mm a').format(checkInTime);
}
