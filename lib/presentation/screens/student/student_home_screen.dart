import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/opportunity_provider.dart';
import '../../../data/models/opportunity_model.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  // Each tab's contents
  final List<Widget> _tabs = const [
    _HomeTab(),
    _SearchTab(),
    _AppsTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
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
          label: 'Apps',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Tab placeholders

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final oppProvider = context.read<OpportunityProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.fullName.split(' ').first ?? 'Student'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Your career dashboard',
                    style: TextStyle(color: AppColors.neutral, fontSize: 13),
                  ),
                ],
              ),
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.neutral,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Search bar (visual only for now) ────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.neutral, size: 18),
                SizedBox(width: 8),
                Text(
                  'Search for opportunities...',
                  style: TextStyle(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Live opportunity feed ────────────────────────────────────
          const Text(
            'Recommended',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<OpportunityModel>>(
            stream: oppProvider.streamActiveOpportunities(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading opportunities',
                    style: const TextStyle(color: AppColors.neutral),
                  ),
                );
              }

              final opportunities = snapshot.data ?? [];

              if (opportunities.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No opportunities yet.\nCheck back soon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.neutral),
                    ),
                  ),
                );
              }

              return ListView.separated(
                // Important: disable ListView's own scroll so it
                // doesn't fight with SingleChildScrollView above it.
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: opportunities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _OpportunityCard(opportunity: opportunities[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Search', style: TextStyle(color: AppColors.neutral)),
  );
}

class _AppsTab extends StatelessWidget {
  const _AppsTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('My Applications', style: TextStyle(color: AppColors.neutral)),
  );
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      onPressed: () => context.read<AuthProvider>().signOut(),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
      child: const Text('Sign Out', style: TextStyle(color: Colors.black)),
    ),
  );
}

class _OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Venture name + verified badge ──────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        opportunity.startupName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (opportunity.isVerifiedVenture) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: AppColors.secondary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const Text(
                    'VENTURE OWNER',
                    style: TextStyle(color: AppColors.neutral, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Title ──────────────────────────────────────────────────
          Text(
            opportunity.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // ── Description preview ────────────────────────────────────
          Text(
            opportunity.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.neutral, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // ── Skill tags ─────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: opportunity.requiredSkills
                .take(3) // never show more than 3 tags on a card
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: AppColors.neutral,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),

          // ── Apply button ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // We'll wire this to the full Opportunity Detail screen next
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${opportunity.title}...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Apply Now ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
