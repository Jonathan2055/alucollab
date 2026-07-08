import 'package:flutter/material.dart';
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ADMIN TERMINAL',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Pending Approvals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Review and verify emerging startups for the ALU Ecosystem.',
                style: TextStyle(color: AppColors.neutral, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // ── Stats grid ───────────────────────────────────────
              StreamBuilder<List<StartupModel>>(
                stream: StartupRepository().streamPendingStartups(),
                builder: (context, snap) {
                  final count = snap.data?.length ?? 0;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _statBox('In Queue', '$count'),
                      _statBox('Approved Today', '0'),
                      _statBox(
                        'High Priority',
                        count > 0 ? '${(count * 0.2).ceil()}' : '0',
                      ),
                      _statBox('Avg. Response', '4.2h'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── List ─────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<StartupModel>>(
                  stream: StartupRepository().streamPendingStartups(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      );
                    }
                    final startups = snapshot.data ?? [];
                    if (startups.isEmpty) {
                      return const Center(
                        child: Text(
                          'No pending startups. All clear! ✅',
                          style: TextStyle(color: AppColors.neutral),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: startups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _StartupApprovalCard(
                        startup: startups[index],
                        index: index,
                      ),
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

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.neutral, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartupApprovalCard extends StatelessWidget {
  final StartupModel startup;
  final int index;
  const _StartupApprovalCard({required this.startup, required this.index});

  @override
  Widget build(BuildContext context) {
    final isFastTrack = index == 0; // first item gets fast track badge for demo
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.background,
                child: Text(
                  startup.name.isNotEmpty ? startup.name[0].toUpperCase() : 'V',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Venture Name: ${startup.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isFastTrack)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.5),
                    ),
                  ),
                  child: const Text(
                    'FAST TRACK',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.neutral,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Owner ID: ${startup.ownerId.substring(0, 8)}...',
                style: const TextStyle(color: AppColors.neutral, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _updateStatus(context, VerificationStatus.rejected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _updateStatus(context, VerificationStatus.approved),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    VerificationStatus status,
  ) async {
    await StartupRepository().updateVerificationStatus(startup.id, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${startup.name} ${status.name}.')));
  }
}
