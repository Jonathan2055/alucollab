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
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentId,
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
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
