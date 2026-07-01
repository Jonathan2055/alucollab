import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.fullName.split(' ').first ?? 'Student'} 👋',
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
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Opportunity feed coming next',
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
