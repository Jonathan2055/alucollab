import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../shared/notification_center_screen.dart';
import '../shared/search_screen.dart';
import 'user_management_screen.dart';
import 'pending_approvals_screen.dart';
import 'moderation_feed_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _CommandCenterTab(onSwitchTab: _switchTab),
      const _SearchTab(),
      const _ApprovalsTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface(context),
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
            icon: Icon(Icons.verified_outlined),
            label: 'Approvals',
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

class _CommandCenterTab extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;
  const _CommandCenterTab({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Header 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Admin Command\nCenter',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen()),
                ),
                child: StreamBuilder<int>(
                  stream: NotificationRepository().streamUnreadCount(
                    context.read<AuthProvider>().currentUser?.uid ?? '',
                  ),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: Icon(Icons.notifications_none_rounded,
                          color: AppColors.icon(context)),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          //  Live stat cards 
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, usersSnap) {
              final userCount = usersSnap.data?.docs.length ?? 0;
              return _statCard(
                context,
                'TOTAL USERS',
                '$userCount',
                '+4 from last month',
                Icons.people_outline,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('opportunities')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, oppSnap) {
              final count = oppSnap.data?.docs.length ?? 0;
              return _statCard(
                context,
                'LIVE POSTS',
                '$count',
                '12 scheduled for today',
                Icons.campaign_outlined,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('startups')
                .where('verificationStatus', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, startupSnap) {
              final count = startupSnap.data?.docs.length ?? 0;
              return _statCard(
                context,
                'PENDING VERIFICATIONS',
                '$count',
                'Critical action required',
                Icons.shield_outlined,
                highlight: count > 0,
              );
            },
          ),
          const SizedBox(height: 20),

          //  Quick actions 
          _actionTile(
            context,
            icon: Icons.flag_outlined,
            title: 'Moderation Feed',
            subtitle: 'Review reported items',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ModerationFeedScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _actionTile(
            context,
            icon: Icons.verified_outlined,
            title: 'Verification Queue',
            subtitle: 'Ventures awaiting approval',
            onTap: () => onSwitchTab(2),
          ),
          const SizedBox(height: 10),
          _actionTile(
            context,
            icon: Icons.manage_accounts_outlined,
            title: 'User Management',
            subtitle: 'Manage ecosystem users',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserManagementScreen()),
            ),
          ),
          const SizedBox(height: 20),

          //  Critical verifications table 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Critical Verifications',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => onSwitchTab(2),
                child: const Text(
                  'View All Queue',
                  style: TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('startups')
                .where('verificationStatus', isEqualTo: 'pending')
                .limit(3)
                .snapshots(),
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text(
                  'No pending verifications.',
                  style: TextStyle(color: AppColors.neutral),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.secondary.withOpacity(0.2),
                          child: Text(
                            (data['name'] as String? ?? 'V')[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            data['name'] ?? 'Unknown',
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Startup',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    IconData icon, {
    bool highlight = false,
  }) {
    final surface = AppColors.surface(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: Colors.redAccent.withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: highlight ? Colors.redAccent : AppColors.textSecondary(context),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: highlight ? Colors.redAccent : AppColors.secondary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: highlight ? Colors.redAccent : AppColors.secondary,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final surface = AppColors.surface(context);
    final textPrimary = AppColors.textPrimary(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: AppColors.secondary, width: 3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.neutral,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.icon(context)),
          ],
        ),
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) => const SearchScreen();
}

class _ApprovalsTab extends StatelessWidget {
  const _ApprovalsTab();
  @override
  Widget build(BuildContext context) => const PendingApprovalsScreen();
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF38BDF8),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Admin',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'ALU Venture Lab Admin',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              //  Theme toggle 
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        themeProvider.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                        color: AppColors.icon(context),
                        size: 20,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                          style: TextStyle(color: AppColors.textPrimary(context)),
                        ),
                      ),
                      Switch(
                        value: themeProvider.isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeColor: AppColors.secondary,
                      ),
                    ],
                  ),
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
