import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'leave_provider.dart';
import '../../core/api/api_client.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';

class DosenLeaveScreen extends ConsumerStatefulWidget {
  const DosenLeaveScreen({super.key});

  @override
  ConsumerState<DosenLeaveScreen> createState() => _DosenLeaveScreenState();
}

class _DosenLeaveScreenState extends ConsumerState<DosenLeaveScreen> {
  int _selectedFilter = 0; // 0 = On Going, 1 = Sudah Lewat

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(leaveRequestsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              title: const Text('Riwayat Izin & Cuti', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 20, letterSpacing: -0.5)),
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
                      child: Icon(Icons.edit_document, size: 120, color: Colors.white.withOpacity(0.15)),
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
                          Icon(Icons.edit_document, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 0 ? 'Tidak ada izin yang sedang berjalan.' : 'Belum ada riwayat izin.', 
                            style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E3192).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      leave['type'].toString().replaceAll('_', ' '),
                                      style: const TextStyle(color: Color(0xFF2E3192), fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), // Hindari tertutup oleh Floating Bottom Nav
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2E3192),
          foregroundColor: Colors.white,
          elevation: 8,
          onPressed: () {
            showDialog(context: context, builder: (_) => const _AddLeaveDialog());
          },
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Buat Pengajuan', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _AddLeaveDialog extends ConsumerStatefulWidget {
  const _AddLeaveDialog();

  @override
  ConsumerState<_AddLeaveDialog> createState() => _AddLeaveDialogState();
}

class _AddLeaveDialogState extends ConsumerState<_AddLeaveDialog> {
  String type = 'SAKIT';
  final reasonController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool isSubmitting = false;

  Future<void> _submit() async {
    if (startDate == null || endDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi form')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/leave-requests', data: {
        'type': type,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'reason': reasonController.text,
      });
      ref.invalidate(leaveRequestsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mengajukan izin')));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent, 
              onPrimary: Colors.white, 
              onSurface: Colors.black87, 
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          startDate = date;
        } else {
          endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buat Pengajuan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: type,
              items: ['IZIN', 'CUTI', 'SAKIT', 'DINAS_LUAR'].map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ')))).toList(),
              onChanged: (v) => setState(() => type = v!),
              decoration: InputDecoration(
                labelText: 'Jenis Pengajuan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickDate(true),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Mulai Tanggal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.blueAccent),
                ),
                child: Text(startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : 'Pilih Tanggal'),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickDate(false),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Sampai Tanggal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.blueAccent),
                ),
                child: Text(endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : 'Pilih Tanggal'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Alasan Lengkap',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submit, 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E3192),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isSubmitting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Text('Kirim Pengajuan'),
        ),
      ],
    );
  }
}
