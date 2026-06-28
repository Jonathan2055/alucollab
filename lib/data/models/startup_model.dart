import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationStatus { pending, approved, rejected }

VerificationStatus _statusFromString(String value) {
  switch (value) {
    case 'approved':
      return VerificationStatus.approved;
    case 'rejected':
      return VerificationStatus.rejected;
    default:
      return VerificationStatus.pending;
  }
}

class StartupModel {
  final String id;
  final String name;
  final String ownerId;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;

  StartupModel({
    required this.id,
    required this.name,
    required this.ownerId,
    this.verificationStatus = VerificationStatus.pending,
    required this.createdAt,
  });

  factory StartupModel.fromMap(String id, Map<String, dynamic> map) {
    return StartupModel(
      id: id,
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      verificationStatus: _statusFromString(
        map['verificationStatus'] ?? 'pending',
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory StartupModel.fromSnapshot(DocumentSnapshot doc) {
    return StartupModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'verificationStatus': verificationStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
