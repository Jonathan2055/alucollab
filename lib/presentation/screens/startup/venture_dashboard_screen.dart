import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/opportunity_model.dart';
import '../../../data/models/startup_model.dart';
import '../../../data/repositories/opportunity_repository.dart';
import '../../../data/repositories/startup_repository.dart';
import '../../../providers/auth_provider.dart';
import '../shared/search_screen.dart';
import 'manage_opportunities_screen.dart';
import 'verification_status_screen.dart';

class VentureDashboardScreen extends StatefulWidget {
  const VentureDashboardScreen({super.key});

  @override
  State<VentureDashboardScreen> createState() => _VentureDashboardScreenState();
}

class _VentureDashboardScreenState extends State<VentureDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    _DashboardTab(),
    _SearchTab(),
    _ManageTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.neutral,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

//  Dashboard Tab 

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<StartupModel?>(
      future: StartupRepository().getStartupByOwner(user.uid),
      builder: (context, snapshot) {
        final startup = snapshot.data;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello, ${user.fullName.split(' ').first} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                startup != null
                    ? 'Venture Dashboard: ${startup.name}'
                    : 'Venture Dashboard',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              //  Verification status banner 
              if (startup != null &&
                  startup.verificationStatus == VerificationStatus.pending)
                _statusBanner(
                  icon: Icons.hourglass_top,
                  color: Colors.orange,
                  message: 'Your venture is awaiting admin verification.',
                ),
              if (startup != null &&
                  startup.verificationStatus == VerificationStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              VerificationStatusScreen(startup: startup),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: BorderSide(
                          color: AppColors.secondary.withOpacity(0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('View Registration Hub →'),
                    ),
                  ),
                ),

              if (startup != null &&
                  startup.verificationStatus == VerificationStatus.approved)
                _statusBanner(
                  icon: Icons.verified,
                  color: AppColors.secondary,
                  message: 'ALU Verified Venture ',
                ),

              if (startup != null &&
                  startup.verificationStatus == VerificationStatus.rejected)
                _statusBanner(
                  icon: Icons.cancel_outlined,
                  color: Colors.redAccent,
                  message: 'Venture was rejected. Contact admin for details.',
                ),

              const SizedBox(height: 8),

              //  Live metrics 
              if (startup != null)
                StreamBuilder<List<OpportunityModel>>(
                  stream: OpportunityRepository().streamStartupOpportunities(
                    startup.id,
                  ),
                  builder: (context, oppSnapshot) {
                    final opps = oppSnapshot.data ?? [];
                    final totalApplicants = opps.fold<int>(
                      0,
                      (sum, o) => sum + o.applicantCount,
                    );

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ACTIVE GROWTH',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${opps.where((o) => o.isActive).length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Active Posts',
                                style: TextStyle(color: AppColors.neutral),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _metricCard(
                                'TALENT POOL',
                                '$totalApplicants',
                                'Total Applicants',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _metricCard(
                                'LISTINGS',
                                '${opps.length}',
                                'Total Posted',
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

              if (startup == null &&
                  snapshot.connectionState == ConnectionState.done)
                const Center(
                  child: Text(
                    'No startup profile found.',
                    style: TextStyle(color: AppColors.neutral),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBanner({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.neutral, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

//  Other Tabs 

class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) => const SearchScreen();
}

class _ManageTab extends StatelessWidget {
  const _ManageTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    return FutureBuilder<StartupModel?>(
      future: StartupRepository().getStartupByOwner(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          );
        }
        final startup = snapshot.data;
        if (startup == null) {
          return const Center(
            child: Text(
              'No startup found.',
              style: TextStyle(color: AppColors.neutral),
            ),
          );
        }
        return ManageOpportunitiesScreen(
          startupId: startup.id,
          startupName: startup.name,
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName[0].toUpperCase()
                            : 'F',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Founder',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Venture Owner',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
