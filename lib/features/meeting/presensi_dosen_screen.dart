import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import '../schedule/schedule_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/api/api_client.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF2E3192),
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
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: const Text('Presensi Kelas', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 24, letterSpacing: -0.5)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(Icons.qr_code_scanner_rounded, size: 120, color: Colors.white.withOpacity(0.15)),
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mata Kuliah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    scheduleAsync.when(
                      data: (schedules) => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.class_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        hint: const Text('Pilih Jadwal'),
                        value: selectedSchedule,
                        isExpanded: true,
                        items: schedules
                            .map((e) => DropdownMenuItem(value: e.scheduleId, child: Text('${e.course?.name} (${e.className})')))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSchedule = v),
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Pertemuan Ke', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.format_list_numbered_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      hint: const Text('Pilih Pertemuan'),
                      value: selectedMeeting,
                      items: List.generate(16, (i) => i + 1)
                          .map((e) => DropdownMenuItem(value: e, child: Text('Pertemuan $e')))
                          .toList(),
                      onChanged: (v) => setState(() => selectedMeeting = v),
                    ),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isOpening || selectedSchedule == null || selectedMeeting == null ? null : _openMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E3192),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        icon: isOpening
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.play_circle_fill_rounded),
                        label: Text(
                          isOpening ? 'Membuka...' : 'Mulai Presensi Kelas',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
