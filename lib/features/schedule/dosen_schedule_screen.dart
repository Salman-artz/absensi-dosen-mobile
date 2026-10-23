import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'schedule_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/utils/report_exporter.dart';

class DosenScheduleScreen extends ConsumerWidget {
  const DosenScheduleScreen({super.key});

  String _getDayName(dynamic dayDynamic) {
    int day = int.tryParse(dayDynamic.toString()) ?? 0;
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    if (day >= 0 && day <= 6) return days[day];
    return 'Hari ke-$day';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsyncValue = ref.watch(myScheduleListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
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
                padding: const EdgeInsets.only(right: 16.0, left: 4.0),
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
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Jadwal Mengajar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kelola kehadiran & rekap presensi kelas',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
            sliver: scheduleAsyncValue.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                              ),
                            ),
                            child: Icon(
                              Icons.event_busy_rounded,
                              size: 56,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tidak ada jadwal mengajar aktif',
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
                      final s = schedules[index];
                      final courseName = s.course?.name ?? 'Mata Kuliah';
                      final className = s.className;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Left accent bar
                                Container(
                                  width: 6,
                                  color: isDark ? AppColors.accent : AppColors.primary,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top Row: Course Name & Class Badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                courseName,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                className,
                                                style: TextStyle(
                                                  color: isDark ? AppColors.accent : AppColors.primary,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // Time & Day
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _getDayName(s.dayOfWeek),
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 16,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}',
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Room
                                        Row(
                                          children: [
                                            const Icon(Icons.room_rounded, size: 16, color: AppColors.statusAlpa),
                                            const SizedBox(width: 6),
                                            Text(
                                              s.room?.name ?? 'Ruangan belum diatur',
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),

                                        // Action Row: Detail Pertemuan & Export Rekap (PDF/Excel)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // Export Button (PDF & Excel)
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                final dio = ref.read(dioProvider);
                                                ReportExporter.showExportBottomSheet(
                                                  context: context,
                                                  dio: dio,
                                                  scheduleId: s.scheduleId,
                                                  courseName: courseName,
                                                  className: className,
                                                );
                                              },
                                              icon: const Icon(Icons.file_download_outlined, size: 16),
                                              label: const Text('Ekspor Rekap', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                              style: OutlinedButton.styleFrom(
                                                minimumSize: Size.zero,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                side: BorderSide(
                                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            // Detail Button
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                context.push('/student-class-detail/${s.scheduleId}');
                                              },
                                              icon: const Icon(Icons.groups_rounded, size: 16),
                                              label: const Text('Detail Presensi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                                                foregroundColor: Colors.white,
                                                minimumSize: Size.zero,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: schedules.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (error, stack) => SliverFillRemaining(child: Center(child: Text('Error: $error'))),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 86.0),
        child: FloatingActionButton.extended(
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          onPressed: () {
            context.push('/scan');
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text(
            'Scan Kehadiran',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
          ),
        ),
      ),
    );
  }
}
