import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  applicationUpdate,
  newApplicant,
  verification,
  moderation,
  system
}

NotificationType _typeFromString(String value) {
  switch (value) {
    case 'applicationUpdate': return NotificationType.applicationUpdate;
    case 'newApplicant': return NotificationType.newApplicant;
    case 'verification': return NotificationType.verification;
    case 'moderation': return NotificationType.moderation;
    default: return NotificationType.system;
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: _typeFromString(map['type'] ?? 'system'),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    return NotificationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}