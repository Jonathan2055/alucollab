import 'package:cloud_firestore/cloud_firestore.dart';

/// The main 3 roles a user in our system.
enum UserRole { student, startupOwner, admin }

UserRole _roleFromString(String value) {
  switch (value) {
    case 'startup_owner':
      return UserRole.startupOwner;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.student;
  }
}

String _roleToString(UserRole role) {
  switch (role) {
    case UserRole.startupOwner:
      return 'startup_owner';
    case UserRole.admin:
      return 'admin';
    case UserRole.student:
      return 'student';
  }
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final UserRole role;
  final String? studentId;
  final List<String> coreCompetencies;
  final String bio;
  final String? linkedinUrl;
  final String? githubUrl;
  final List<String> experience;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentId,
    this.coreCompetencies = const [],
    this.bio = '',
    this.linkedinUrl,
    this.githubUrl,
    this.experience = const [],
    required this.createdAt,
  });

  /// Builds a UserModel from a Firestore document's data map.
  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: _roleFromString(map['role'] ?? 'student'),
      studentId: map['studentId'],
      coreCompetencies: List<String>.from(map['coreCompetencies'] ?? []),
      bio: map['bio'] ?? '',
      linkedinUrl: map['linkedinUrl'],
      githubUrl: map['githubUrl'],
      experience: List<String>.from(map['experience'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convenience: build directly from a DocumentSnapshot.
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// Converts this object into a map ready to send to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': _roleToString(role),
      'studentId': studentId,
      'coreCompetencies': coreCompetencies,
      'bio': bio,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'experience': experience,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
