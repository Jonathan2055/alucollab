import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../providers/auth_provider.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.applicationUpdate:
        return Icons.work_outline;
      case NotificationType.newApplicant:
        return Icons.person_add_outlined;
      case NotificationType.verification:
        return Icons.verified_outlined;
      case NotificationType.moderation:
        return Icons.flag_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    final notifRepo = NotificationRepository();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Notifications',
            style:
                TextStyle(color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => notifRepo.markAllAsRead(user.uid),
            child: const Text('Mark all read',
                style: TextStyle(color: AppColors.secondary, fontSize: 12)),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notifRepo.streamUserNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.secondary));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none_outlined,
                      color: AppColors.neutral, size: 56),
                  const SizedBox(height: 12),
                  Text('No notifications yet.',
                      style: TextStyle(
                          color: AppColors.textSecondary(context))),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return GestureDetector(
                onTap: () => notifRepo.markAsRead(notif.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.isRead
                        ? AppColors.surface(context)
                        : AppColors.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: notif.isRead
                        ? null
                        : Border.all(
                            color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_iconForType(notif.type),
                            color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(notif.title,
                                      style: TextStyle(
                                          color: AppColors.textPrimary(context),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                                if (!notif.isRead)
                                  Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(notif.message,
                                style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 13,
                                    height: 1.4)),
                            const SizedBox(height: 6),
                            Text(_timeAgo(notif.createdAt),
                                style: const TextStyle(
                                    color: AppColors.neutral, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}