import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/application_model.dart';
import '../../../data/repositories/application_repository.dart';
import '../../../providers/auth_provider.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Track Your Journey',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('Your active applications in the ALU ecosystem.',
                  style: TextStyle(color: AppColors.neutral, fontSize: 13)),
              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<ApplicationModel>>(
                  stream: ApplicationRepository().streamStudentApplications(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                    }

                    final apps = snapshot.data ?? [];

                    if (apps.isEmpty) {
                      return const Center(
                        child: Text('No applications yet.\nStart applying to opportunities!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.neutral)),
                      );
                    }

                    return ListView.separated(
                      itemCount: apps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _ApplicationCard(app: apps[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;
  const _ApplicationCard({required this.app});

  Color get _statusColor {
    switch (app.status) {
      case ApplicationStatus.accepted: return AppColors.secondary;
      case ApplicationStatus.interview: return AppColors.tertiary;
      case ApplicationStatus.withdrawn: return AppColors.neutral;
      default: return Colors.orangeAccent;
    }
  }

  String get _statusLabel {
    switch (app.status) {
      case ApplicationStatus.accepted: return 'Accepted';
      case ApplicationStatus.interview: return 'Interview';
      case ApplicationStatus.withdrawn: return 'Withdrawn';
      default: return 'Applied';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _statusColor, width: 3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.rocket_launch, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.startupName,
                    style: const TextStyle(color: AppColors.neutral, fontSize: 12)),
                Text(app.opportunityTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Applied ${_timeAgo(app.appliedAt)}',
                    style: const TextStyle(color: AppColors.neutral, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}