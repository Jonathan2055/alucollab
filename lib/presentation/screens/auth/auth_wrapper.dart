import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';
import '../student/student_home_screen.dart';
import '../startup/venture_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();

    return StreamBuilder(
      stream: authRepo.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (!authSnapshot.hasData) {
          return const WelcomeScreen();
        }

        final uid = authSnapshot.data!.uid;

        return FutureBuilder<UserModel>(
          future: authRepo.getUserProfile(uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (userSnapshot.hasError || !userSnapshot.hasData) {
              authRepo.signOut();
              return const WelcomeScreen();
            }

            final user = userSnapshot.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthProvider>().setCurrentUser(user);
            });

            switch (user.role) {
              case UserRole.admin:
                return const AdminDashboardScreen();
              case UserRole.startupOwner:
                return const VentureDashboardScreen();
              case UserRole.student:
                return const StudentHomeScreen();
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
