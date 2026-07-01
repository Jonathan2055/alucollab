import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { applied, interview, accepted, withdrawn }

ApplicationStatus _statusFromString(String value) {
  switch (value) {
    case 'interview': return ApplicationStatus.interview;
    case 'accepted': return ApplicationStatus.accepted;
    case 'withdrawn': return ApplicationStatus.withdrawn;
    default: return ApplicationStatus.applied;
  }
}

class ApplicationModel {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;       // the user UID, not ALU ID
  final ApplicationStatus status;
  final DateTime appliedAt;

  ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    this.status = ApplicationStatus.applied,
    required this.appliedAt,
  });

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplicationModel(
      id: id,
      opportunityId: map['opportunityId'] ?? '',
      opportunityTitle: map['opportunityTitle'] ?? '',
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      studentId: map['studentId'] ?? '',
      status: _statusFromString(map['status'] ?? 'applied'),
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ApplicationModel.fromSnapshot(DocumentSnapshot doc) {
    return ApplicationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentId': studentId,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }
}