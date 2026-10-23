import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'notification_provider.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Future<void> _markAsRead(String id, bool alreadyRead) async {
    if (alreadyRead) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/notifications/$id/read');
      ref.invalidate(notificationsProvider);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primaryDark,
            actions: [
              IconButton(
                tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                ),
                onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    tooltip: 'Keluar',
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: const Text(
                'Notifikasi',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 130,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
            sliver: notifAsync.when(
              data: (notifs) {
                if (notifs.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_paused_rounded,
                            size: 70,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada notifikasi baru',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = notifs[index];
                      final isRead = notif['isRead'] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (isRead ? AppColors.darkSurface : AppColors.darkSurfaceVariant)
                              : (isRead ? AppColors.surface : const Color(0xFFEEF2FF)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? (isDark ? AppColors.darkBorder : AppColors.border)
                                : (isDark ? AppColors.accent.withOpacity(0.4) : AppColors.primary.withOpacity(0.4)),
                            width: isRead ? 1 : 1.5,
                          ),
                          boxShadow: [
                            if (!isRead)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? (isDark ? AppColors.darkBorder : AppColors.surfaceVariant)
                                  : (isDark ? AppColors.accent.withOpacity(0.2) : AppColors.primary.withOpacity(0.12)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                              color: isRead
                                  ? (isDark ? AppColors.darkTextMuted : AppColors.textMuted)
                                  : (isDark ? AppColors.accent : AppColors.primary),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            notif['title'] ?? '-',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              color: isRead
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                                  : (isDark ? AppColors.accent : AppColors.primary),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              notif['message'] ?? '-',
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                height: 1.3,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          onTap: () => _markAsRead(notif['notificationId'], isRead),
                        ),
                      );
                    },
                    childCount: notifs.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, s) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            ),
          ),
        ],
      ),
    );
  }
}
