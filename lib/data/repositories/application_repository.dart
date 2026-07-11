import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationRepository _notifRepo = NotificationRepository();

  Future<void> applyToOpportunity(ApplicationModel application) async {
    // Save application
    final docRef = await _firestore
        .collection('applications')
        .add(application.toMap());

    // Notify the startup owner that a new student applied
    // We need the startup owner's uid — fetch from startups collection
    final startupDoc = await _firestore
        .collection('startups')
        .doc(application.startupId)
        .get();

    if (startupDoc.exists) {
      final ownerId = startupDoc.data()?['ownerId'] as String?;
      if (ownerId != null) {
        await _notifRepo.sendNotification(
          userId: ownerId,
          title: 'New Application Received',
          message: 'A student applied for ${application.opportunityTitle}',
          type: NotificationType.newApplicant,
        );
      }
    }
  }

  Stream<List<ApplicationModel>> streamStudentApplications(String studentId) {
    return _firestore
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ApplicationModel.fromSnapshot(d))
            .toList());
  }

  Stream<List<ApplicationModel>> streamStartupApplications(String startupId) {
    return _firestore
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ApplicationModel.fromSnapshot(d))
            .toList());
  }

  /// Stream applications for a specific opportunity
  Stream<List<ApplicationModel>> streamOpportunityApplications(
      String opportunityId) {
    return _firestore
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ApplicationModel.fromSnapshot(d))
            .toList());
  }

  /// Update status AND notify the student
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
    String studentId,
    String opportunityTitle,
  ) async {
    await _firestore
        .collection('applications')
        .doc(applicationId)
        .update({'status': status.name});

    // Send targeted notification to the student
    String title;
    String message;
    NotificationType type;

    switch (status) {
      case ApplicationStatus.interview:
        title = 'Interview Invitation!';
        message =
            'You\'ve been invited for an interview for $opportunityTitle. Check your email for details.';
        type = NotificationType.applicationUpdate;
        break;
      case ApplicationStatus.accepted:
        title = 'Application Accepted!';
        message =
            'Congratulations! You\'ve been accepted for $opportunityTitle. Welcome to the team!';
        type = NotificationType.applicationUpdate;
        break;
      case ApplicationStatus.withdrawn:
        title = 'Application Withdrawn';
        message = 'Your application for $opportunityTitle has been withdrawn.';
        type = NotificationType.applicationUpdate;
        break;
      default:
        return; // Don't notify for 'applied' status
    }

    await _notifRepo.sendNotification(
      userId: studentId,
      title: title,
      message: message,
      type: type,
    );
  }
}