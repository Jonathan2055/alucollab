import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> applyToOpportunity(ApplicationModel application) async {
    await _firestore.collection('applications').add(application.toMap());
  }

  Stream<List<ApplicationModel>> streamStudentApplications(String studentId) {
    return _firestore
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) => s.docs.map((d) => ApplicationModel.fromSnapshot(d)).toList());
  }

  Stream<List<ApplicationModel>> streamStartupApplications(String startupId) {
    return _firestore
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((s) => s.docs.map((d) => ApplicationModel.fromSnapshot(d)).toList());
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': status.name,
    });
  }
}