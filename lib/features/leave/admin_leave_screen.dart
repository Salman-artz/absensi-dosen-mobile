import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'leave_provider.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import 'package:intl/intl.dart';

class AdminLeaveScreen extends ConsumerStatefulWidget {
  const AdminLeaveScreen({super.key});

  @override
  ConsumerState<AdminLeaveScreen> createState() => _AdminLeaveScreenState();
}

class _AdminLeaveScreenState extends ConsumerState<AdminLeaveScreen> {
  int _selectedFilter = 0; // 0 = On Going, 1 = Sudah Lewat

  Future<void> _updateStatus(String id, String status) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/leave-requests/$id/decision', data: {
        'decision': status,
      });
      ref.invalidate(leaveRequestsProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status diubah menjadi $status')));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(leaveRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
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
              title: const Text('Persetujuan Izin', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 24, letterSpacing: -0.5)),
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
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(Icons.approval_rounded, size: 140, color: Colors.white.withOpacity(0.15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedFilter == 0 ? const Color(0xFF2E3192) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _selectedFilter == 0 ? const Color(0xFF2E3192) : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'Sedang Berjalan',
                            style: TextStyle(
                              color: _selectedFilter == 0 ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedFilter == 1 ? const Color(0xFF2E3192) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _selectedFilter == 1 ? const Color(0xFF2E3192) : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            'Sudah Lewat',
                            style: TextStyle(
                              color: _selectedFilter == 1 ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
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
                    // Sedang Berjalan: Belum ditolak DAN tanggal selesai belum lewat
                    return !isRejected && (endDay.isAfter(today) || endDay.isAtSameMomentAs(today));
                  } else {
                    // Sudah Lewat: Sudah ditolak ATAU tanggal selesai sudah lewat
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
                          Icon(Icons.approval_rounded, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 0 ? 'Tidak ada pengajuan izin berjalan' : 'Belum ada riwayat izin', 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold)
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
                      Color badgeColor = Colors.grey;
                      Color badgeBg = Colors.grey.shade100;
                      IconData statusIcon = Icons.hourglass_empty;
                      if (leave['status'] == 'PENDING') {
                        badgeColor = Colors.orange;
                        badgeBg = Colors.orange.shade50;
                        statusIcon = Icons.pending_actions_rounded;
                      }
                      if (leave['status'] == 'APPROVED') {
                        badgeColor = Colors.green;
                        badgeBg = Colors.green.shade50;
                        statusIcon = Icons.check_circle_rounded;
                      }
                      if (leave['status'] == 'REJECTED') {
                        badgeColor = Colors.red;
                        badgeBg = Colors.red.shade50;
                        statusIcon = Icons.cancel_rounded;
                      }

                      final format = DateFormat('dd MMM yyyy');
                      final start = format.format(DateTime.parse(leave['startDate']));
                      final end = format.format(DateTime.parse(leave['endDate']));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF2E3192).withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFFE8FAFF),
                                        foregroundColor: const Color(0xFF2E3192),
                                        child: const Icon(Icons.person_rounded),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(leave['lecturer']['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text(leave['type'].toString().replaceAll('_', ' '), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: badgeBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: badgeColor.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon, size: 14, color: badgeColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          leave['status'],
                                          style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.date_range_rounded, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text('$start  s/d  $end', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Alasan:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(leave['reason'] ?? '-', style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                              ),
                              if (leave['status'] == 'PENDING') ...[
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _updateStatus(leave['id'], 'REJECTED'),
                                      icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                                      label: const Text('Tolak', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _updateStatus(leave['id'], 'APPROVED'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.check_rounded),
                                      label: const Text('Setujui', style: TextStyle(fontWeight: FontWeight.bold)),
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
