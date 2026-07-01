import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityModel {
  final String id;
  final String startupId;
  final String startupName;
  final bool isVerifiedVenture;
  final String title;
  final String category;
  final String description;
  final List<String> requiredSkills;
  final int durationMonths;
  final bool isActive;
  final int applicantCount;
  final DateTime createdAt;

  OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    this.isVerifiedVenture = false,
    required this.title,
    required this.category,
    required this.description,
    this.requiredSkills = const [],
    required this.durationMonths,
    this.isActive = true,
    this.applicantCount = 0,
    required this.createdAt,
  });

  factory OpportunityModel.fromMap(String id, Map<String, dynamic> map) {
    return OpportunityModel(
      id: id,
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      isVerifiedVenture: map['isVerifiedVenture'] ?? false,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      durationMonths: map['durationMonths'] ?? 1,
      isActive: map['isActive'] ?? true,
      applicantCount: map['applicantCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory OpportunityModel.fromSnapshot(DocumentSnapshot doc) {
    return OpportunityModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'isVerifiedVenture': isVerifiedVenture,
      'title': title,
      'category': category,
      'description': description,
      'requiredSkills': requiredSkills,
      'durationMonths': durationMonths,
      'isActive': isActive,
      'applicantCount': applicantCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
