import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'schedule_provider.dart';
import '../auth/auth_provider.dart';

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
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    tooltip: 'Keluar',
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
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
                                'Halo, Dosen!',
                                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Jadwal Anda hari ini',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
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
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
                            child: const Icon(Icons.event_busy_rounded, size: 60, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          const Text('Tidak ada jadwal mengajar', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final s = schedules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF2E3192).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Left accent bar
                                Container(width: 8, color: const Color(0xFF1BFFFF)),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                s.course?.name ?? 'Unknown Course',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2E3192), height: 1.2),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(color: const Color(0xFF2E3192).withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                                              child: Text(s.className, style: const TextStyle(color: Color(0xFF2E3192), fontWeight: FontWeight.w800, fontSize: 13)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(_getDayName(s.dayOfWeek), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                            const SizedBox(width: 20),
                                            const Icon(Icons.access_time_rounded, size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text('${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.room_rounded, size: 18, color: Colors.redAccent),
                                            const SizedBox(width: 8),
                                            Text(s.room?.name ?? '-', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
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
        padding: const EdgeInsets.only(bottom: 90.0), // Hindari tertutup oleh Floating Bottom Nav
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2E3192),
          foregroundColor: Colors.white,
          elevation: 8,
          onPressed: () {
            context.push('/scan');
          },
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan Kehadiran', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}
