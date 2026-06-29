import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import 'login_screen.dart';

// this Decides what the user sees first(If it login or if it's dashbord)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();

    return StreamBuilder(
      stream: authRepo.authStateChanges,
      builder: (context, authSnapshot) {
        // checking if a session exists
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // When no one logged in
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        // if someone is logged in. now fetch their role from Firestore
        final uid = authSnapshot.data!.uid;

        return FutureBuilder<UserModel>(
          future: authRepo.getUserProfile(uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (userSnapshot.hasError || !userSnapshot.hasData) {
              // Profile lookup failed, move  to Login screen
              authRepo.signOut();
              return const LoginScreen();
            }

            final user = userSnapshot.data!;

            switch (user.role) {
              case UserRole.admin:
                return const _PlaceholderScreen(label: 'ADMIN COMMAND CENTER');
              case UserRole.startupOwner:
                return const _PlaceholderScreen(label: 'VENTURE DASHBOARD');
              case UserRole.student:
                return const _PlaceholderScreen(label: 'STUDENT HOME');
            }
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF))),
    );
  }
}

// Temporary stand-in so we can prove routing works before
class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2DD4BF),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
