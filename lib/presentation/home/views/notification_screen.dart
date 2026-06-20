import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../viewmodels/notification_viewmodel.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();
    final notifications = viewModel.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const AppText.titleMedium(
          'Notifications',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                viewModel.markAllAsRead();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.buttonColor,
              ),
              child: const AppText.bodySmall(
                'Mark all read',
                fontWeight: FontWeight.w600,
                color: AppColors.buttonColor,
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 48,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AppText.titleMedium(
                    'No notifications yet',
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  const AppText.bodyMedium(
                    'When you get notifications, they will show up here.',
                    color: AppColors.textDisabled,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.border,
                indent: 76,
              ),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                
                return InkWell(
                  onTap: () {
                    viewModel.markAsRead(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: notification.isRead 
                        ? Colors.transparent 
                        : AppColors.buttonColor.withValues(alpha: 0.03),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: notification.isRead
                                ? AppColors.surface
                                : AppColors.buttonColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            notification.isRead
                                ? Icons.notifications_none_rounded
                                : Icons.notifications_active_rounded,
                            size: 24,
                            color: notification.isRead
                                ? AppColors.textDisabled
                                : AppColors.buttonColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: notification.isRead
                                      ? AppColors.textPrimary.withValues(alpha: 0.8)
                                      : AppColors.textPrimary,
                                ),
                                child: Text(notification.title),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppColors.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 8, left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.buttonColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
