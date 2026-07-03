import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'pending_approvals_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    _CommandCenterTab(),
    _SearchTab(),
    _ModerationTab(),
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

class _CommandCenterTab extends StatelessWidget {
  const _CommandCenterTab();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Admin Command Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.notifications_none_rounded, color: AppColors.neutral),
            ],
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Admin metrics coming next',
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

class _ModerationTab extends StatelessWidget {
  const _ModerationTab();
  @override
  Widget build(BuildContext context) => const PendingApprovalsScreen();
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
