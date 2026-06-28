import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/startup_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates athentication for user
  Future<UserModel> signUpStudent({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    // Create login credential in Firebase Auth.
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // build our UserModel object.
    final newUser = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      role: UserRole.student,
      studentId: studentId,
      createdAt: DateTime.now(),
    );

    // Save that object into Firestore under /users/{uid}.
    await _firestore.collection('users').doc(uid).set(newUser.toMap());

    return newUser;
  }

  /// Creates a Auth account for a startup owner
  Future<UserModel> signUpStartupOwner({
    required String fullName,
    required String startupName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final newUser = UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      role: UserRole.startupOwner,
      createdAt: DateTime.now(),
    );

    final newStartup = StartupModel(
      id: '',
      name: startupName,
      ownerId: uid,
      verificationStatus: VerificationStatus.pending,
      createdAt: DateTime.now(),
    );

    // I used a batch write so both documents succeed or both fail
    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(uid);
    batch.set(userRef, newUser.toMap());

    final startupRef = _firestore.collection('startups').doc();
    batch.set(startupRef, newStartup.toMap());

    await batch.commit();

    return newUser;
  }
}
