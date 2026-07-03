import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

class StartupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StartupModel?> getStartupByOwner(String ownerId) async {
    final query = await _firestore
        .collection('startups')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return StartupModel.fromSnapshot(query.docs.first);
  }

  Stream<List<StartupModel>> streamPendingStartups() {
    return _firestore
        .collection('startups')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map((d) => StartupModel.fromSnapshot(d)).toList());
  }

  Future<void> updateVerificationStatus(String startupId, VerificationStatus status) async {
    await _firestore.collection('startups').doc(startupId).update({
      'verificationStatus': status.name,
    });
  }
}