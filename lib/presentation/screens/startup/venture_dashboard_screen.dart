import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

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
          label: 'Manage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello, ${user?.fullName.split(' ').first ?? 'Founder'}',
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
          const SizedBox(height: 8),
          const Text(
            'Venture Dashboard',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Venture metrics coming next',
              style: TextStyle(color: AppColors.neutral),
            ),
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

class _ManageTab extends StatelessWidget {
  const _ManageTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Manage Opportunities',
      style: TextStyle(color: AppColors.neutral),
    ),
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
