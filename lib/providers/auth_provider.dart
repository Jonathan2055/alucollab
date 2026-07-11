  import 'package:flutter/material.dart';
  import '../data/repositories/auth_repository.dart';
  import '../data/models/user_model.dart';

  // Holds the currently logged-in user's profile and loading/error state instead of re-fetching Firestore itself.
  class AuthProvider extends ChangeNotifier {
    final AuthRepository _authRepo = AuthRepository();

    UserModel? _currentUser;
    bool _isLoading = false;
    String? _errorMessage;

    UserModel? get currentUser => _currentUser;
    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;

    Future<void> signIn({required String email, required String password}) async {
      _setLoading(true);
      try {
        _currentUser = await _authRepo.signIn(email: email, password: password);
        _errorMessage = null;
      } catch (e) {
        _errorMessage = e.toString();
        rethrow; // let the screen's try/catch still show its own snackbar
      } finally {
        _setLoading(false);
      }
    }

    Future<void> signUpStudent({
      required String fullName,
      required String studentId,
      required String email,
      required String password,
    }) async {
      _setLoading(true);
      try {
        _currentUser = await _authRepo.signUpStudent(
          fullName: fullName,
          studentId: studentId,
          email: email,
          password: password,
        );
      } finally {
        _setLoading(false);
      }
    }

    Future<void> signUpStartupOwner({
      required String fullName,
      required String startupName,
      required String email,
      required String password,
    }) async {
      _setLoading(true);
      try {
        _currentUser = await _authRepo.signUpStartupOwner(
          fullName: fullName,
          startupName: startupName,
          email: email,
          password: password,
        );
      } finally {
        _setLoading(false);
      }
    }

    Future<void> loadUserProfile(String uid) async {
      _currentUser = await _authRepo.getUserProfile(uid);
      notifyListeners();
    }
    void setCurrentUser(UserModel user) {
        _currentUser = user;
        notifyListeners();
      
    }
    Future<void> signOut() async {
      await _authRepo.signOut();
      _currentUser = null;
      notifyListeners();
    }

    void _setLoading(bool value) {
      _isLoading = value;
      notifyListeners();
    }
  }
