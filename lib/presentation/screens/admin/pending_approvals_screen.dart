import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/startup_model.dart';
import '../../../data/repositories/startup_repository.dart';

class PendingApprovalsScreen extends StatelessWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ADMIN TERMINAL',
                  style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Pending Approvals',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const Text('Review and verify emerging startups.',
                  style: TextStyle(color: AppColors.neutral, fontSize: 13)),
              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<StartupModel>>(
                  stream: StartupRepository().streamPendingStartups(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
                    }

                    final startups = snapshot.data ?? [];

                    if (startups.isEmpty) {
                      return const Center(
                        child: Text('No pending startups. All clear! ✅',
                            style: TextStyle(color: AppColors.neutral)),
                      );
                    }

                    return ListView.separated(
                      itemCount: startups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _StartupApprovalCard(startup: startups[index]);
                      },
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

class _StartupApprovalCard extends StatelessWidget {
  final StartupModel startup;
  const _StartupApprovalCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(startup.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Owner ID: ${startup.ownerId}',
              style: const TextStyle(color: AppColors.neutral, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, VerificationStatus.rejected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.2),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, VerificationStatus.approved),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Approve', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, VerificationStatus status) async {
    await StartupRepository().updateVerificationStatus(startup.id, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${startup.name} ${status.name}.')),
    );
  }
}