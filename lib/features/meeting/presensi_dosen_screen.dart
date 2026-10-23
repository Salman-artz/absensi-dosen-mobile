import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../schedule/schedule_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class PresensiDosenScreen extends ConsumerStatefulWidget {
  const PresensiDosenScreen({super.key});

  @override
  ConsumerState<PresensiDosenScreen> createState() => _PresensiDosenScreenState();
}

class _PresensiDosenScreenState extends ConsumerState<PresensiDosenScreen> {
  String? selectedSchedule;
  int? selectedMeeting;
  bool isOpening = false;

  Future<void> _openMeeting() async {
    if (selectedSchedule == null || selectedMeeting == null) return;
    setState(() => isOpening = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/meetings', data: {
        'scheduleId': selectedSchedule,
        'meetingNumber': selectedMeeting,
      });
      final meetingId = res.data['data']['id'];
      if (mounted) {
        context.push('/meeting-attendance/$meetingId');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gagal membuka pertemuan';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(myScheduleListProvider);
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
                'Presensi Kelas',
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
                        Icons.qr_code_scanner_rounded,
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
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(22),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Mata Kuliah',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    scheduleAsync.when(
                      data: (schedules) => DropdownButtonFormField<String>(
                        dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                        hint: const Text('Pilih Jadwal Mengajar'),
                        value: selectedSchedule,
                        isExpanded: true,
                        items: schedules
                            .map((e) => DropdownMenuItem(
                                  value: e.scheduleId,
                                  child: Text(
                                    '${e.course?.name} (${e.className})',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSchedule = v),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      'Pertemuan Ke',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.format_list_numbered_rounded),
                      ),
                      hint: const Text('Pilih Pertemuan (1 - 16)'),
                      value: selectedMeeting,
                      items: List.generate(16, (i) => i + 1)
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e == 8 ? 'Pertemuan 8 (UTS)' : (e == 16 ? 'Pertemuan 16 (UAS)' : 'Pertemuan $e'),
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedMeeting = v),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isOpening || selectedSchedule == null || selectedMeeting == null ? null : _openMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: isOpening
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
                        label: Text(
                          isOpening ? 'Membuka Pertemuan...' : 'Mulai Presensi Kelas',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
