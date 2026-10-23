import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'leave_provider.dart';
import '../../core/api/api_client.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class AdminLeaveScreen extends ConsumerStatefulWidget {
  const AdminLeaveScreen({super.key});

  @override
  ConsumerState<AdminLeaveScreen> createState() => _AdminLeaveScreenState();
}

class _AdminLeaveScreenState extends ConsumerState<AdminLeaveScreen> {
  int _selectedFilter = 0; // 0 = Sedang Berjalan, 1 = Sudah Lewat

  Future<void> _updateStatus(String leaveId, String status) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/leaves/$leaveId/status', data: {
        'status': status,
      });
      ref.invalidate(leaveRequestsProvider);
      if (mounted) {
        final label = status == 'APPROVED' ? 'disetujui' : 'ditolak';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengajuan izin berhasil $label'),
            backgroundColor: status == 'APPROVED' ? AppColors.statusHadir : AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui status: $msg'), backgroundColor: AppColors.statusAlpa),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(leaveRequestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
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
                'Persetujuan Izin',
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
                        Icons.approval_rounded,
                        size: 140,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Segment Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = 0),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedFilter == 0
                              ? (isDark ? AppColors.primaryLight : AppColors.primary)
                              : (isDark ? AppColors.darkSurface : AppColors.surface),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedFilter == 0
                                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Sedang Berjalan',
                            style: TextStyle(
                              color: _selectedFilter == 0
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = 1),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedFilter == 1
                              ? (isDark ? AppColors.primaryLight : AppColors.primary)
                              : (isDark ? AppColors.darkSurface : AppColors.surface),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _selectedFilter == 1
                                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                : (isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Sudah Lewat',
                            style: TextStyle(
                              color: _selectedFilter == 1
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
            sliver: leaveAsync.when(
              data: (allLeaves) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                final leaves = allLeaves.where((leave) {
                  final endDate = DateTime.parse(leave['endDate']);
                  final endDay = DateTime(endDate.year, endDate.month, endDate.day);
                  final isRejected = leave['status'] == 'REJECTED';

                  if (_selectedFilter == 0) {
                    return !isRejected && (endDay.isAfter(today) || endDay.isAtSameMomentAs(today));
                  } else {
                    return isRejected || endDay.isBefore(today);
                  }
                }).toList();

                if (leaves.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.approval_rounded,
                            size: 70,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 0 ? 'Tidak ada pengajuan izin berjalan' : 'Belum ada riwayat izin',
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
                      final leave = leaves[index];
                      Color badgeColor = AppColors.textMuted;
                      Color badgeBg = isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
                      IconData statusIcon = Icons.hourglass_empty;

                      if (leave['status'] == 'PENDING') {
                        badgeColor = AppColors.statusTelat;
                        badgeBg = AppColors.getStatusBgColor('TELAT', isDark: isDark);
                        statusIcon = Icons.pending_actions_rounded;
                      } else if (leave['status'] == 'APPROVED') {
                        badgeColor = AppColors.statusHadir;
                        badgeBg = AppColors.getStatusBgColor('HADIR', isDark: isDark);
                        statusIcon = Icons.check_circle_rounded;
                      } else if (leave['status'] == 'REJECTED') {
                        badgeColor = AppColors.statusAlpa;
                        badgeBg = AppColors.getStatusBgColor('ALPHA', isDark: isDark);
                        statusIcon = Icons.cancel_rounded;
                      }

                      final format = DateFormat('dd MMM yyyy');
                      final start = format.format(DateTime.parse(leave['startDate']));
                      final end = format.format(DateTime.parse(leave['endDate']));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                                        foregroundColor: isDark ? AppColors.accent : AppColors.primary,
                                        child: const Icon(Icons.person_rounded),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            leave['lecturer']['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            leave['type'].toString().replaceAll('_', ' '),
                                            style: TextStyle(
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: badgeBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, size: 14, color: badgeColor),
                                        const SizedBox(width: 5),
                                        Text(
                                          leave['status'],
                                          style: TextStyle(
                                            color: badgeColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(
                                    Icons.date_range_rounded,
                                    size: 16,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$start  s/d  $end',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Alasan:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      leave['reason'] ?? '-',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (leave['status'] == 'PENDING') ...[
                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _updateStatus(leave['id'], 'REJECTED'),
                                      icon: const Icon(Icons.close_rounded, color: AppColors.statusAlpa, size: 18),
                                      label: const Text(
                                        'Tolak',
                                        style: TextStyle(color: AppColors.statusAlpa, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _updateStatus(leave['id'], 'APPROVED'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.statusHadir,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.check_rounded, size: 16),
                                      label: const Text(
                                        'Setujui',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: leaves.length,
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
