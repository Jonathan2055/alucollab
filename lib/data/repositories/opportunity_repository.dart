import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class OpportunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Streams ALL active opportunities and this powers the Student Home feed.
Stream<List<OpportunityModel>> streamActiveOpportunities() {
  return _firestore
      .collection('opportunities')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final opportunities = snapshot.docs
            .map((doc) => OpportunityModel.fromSnapshot(doc))
            .toList();

        opportunities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return opportunities;
      });
}

  // Streams opportunities belonging to one startup and powers the Manage screen.
  // We sort locally to avoid needing a Firestore composite index.
  Stream<List<OpportunityModel>> streamStartupOpportunities(String startupId) {
    return _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
          final opportunities = snapshot.docs
              .map((doc) => OpportunityModel.fromSnapshot(doc))
              .toList();

          opportunities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return opportunities;
        });
  }

  // Startup owner posts a new opportunity.
  Future<void> createOpportunity(OpportunityModel opportunity) async {
    await _firestore.collection('opportunities').add(opportunity.toMap());
  }

  // Startup owner removes their own listing.
  Future<void> deleteOpportunity(String opportunityId) async {
    await _firestore.collection('opportunities').doc(opportunityId).delete();
  }

  // Admins removes inappropriate content globally.
  Future<void> adminDeleteOpportunity(String opportunityId) async {
    await _firestore.collection('opportunities').doc(opportunityId).delete();
  }

  // Increments applicant count automically when a student applies.
  Future<void> incrementApplicantCount(String opportunityId) async {
    await _firestore.collection('opportunities').doc(opportunityId).update({
      'applicantCount': FieldValue.increment(1),
    });
  }
}
