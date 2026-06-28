import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates an account
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
}
