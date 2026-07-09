import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/startup_model.dart';

class VerificationStatusScreen extends StatelessWidget {
  final StartupModel startup;
  const VerificationStatusScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.rocket_launch, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('ALU Venture Lab',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 28),

              // ── Status badge ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neutral.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock_outline, color: AppColors.neutral, size: 12),
                    SizedBox(width: 6),
                    Text('AWAITING VERIFICATION',
                        style: TextStyle(color: AppColors.neutral, fontSize: 11,
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Registration Hub',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const Text('Your startup profile is being prioritized by our\nVenture Lab team.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.neutral, fontSize: 13, height: 1.5)),
              const SizedBox(height: 28),

              // ── Processing circle ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.schedule, color: AppColors.secondary, size: 36),
                          SizedBox(height: 4),
                          Text('Processing',
                              style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Application Sent to ALU\nVenture Lab',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Our team is currently reviewing your mission\nstatement and market fit. Expected\nturnaround: 2-3 business days.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.neutral, fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Progress steps ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _step('Submitted', true, true),
                  _stepLine(),
                  _step('Under Review', true, false),
                  _stepLine(),
                  _step('Active', false, false),
                ],
              ),
              const SizedBox(height: 24),

              // ── Next steps ───────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('NEXT STEPS',
                        style: TextStyle(
                            color: AppColors.neutral,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    Text('2 Actions Pending',
                        style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _nextStepTile(Icons.person_add_outlined, 'Complete your profile',
                  'Boost your visibility to elite ALU talent by 40%.'),
              const SizedBox(height: 10),
              _nextStepTile(Icons.share_outlined, 'Invite Co-founders',
                  'Add team members to manage hiring collab.'),
              const SizedBox(height: 24),

              const Text('Need urgent assistance?',
                  style: TextStyle(color: AppColors.neutral)),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF334155)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Contact Venture Lab Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String label, bool active, bool completed) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed || active ? AppColors.secondary : const Color(0xFF1E293B),
            border: Border.all(
              color: active ? AppColors.secondary : AppColors.neutral.withOpacity(0.3),
            ),
          ),
          child: Icon(
            completed ? Icons.check : Icons.refresh,
            color: completed || active ? Colors.black : AppColors.neutral,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: active ? AppColors.secondary : AppColors.neutral, fontSize: 10)),
      ],
    );
  }

  Widget _stepLine() {
    return Container(
        width: 40, height: 2, margin: const EdgeInsets.only(bottom: 20),
        color: AppColors.secondary.withOpacity(0.4));
  }

  Widget _nextStepTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.neutral, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.neutral),
        ],
      ),
    );
  }
}