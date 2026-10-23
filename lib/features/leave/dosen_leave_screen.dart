import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'leave_provider.dart';
import '../../core/api/api_client.dart';
import 'package:intl/intl.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class DosenLeaveScreen extends ConsumerStatefulWidget {
  const DosenLeaveScreen({super.key});

  @override
  ConsumerState<DosenLeaveScreen> createState() => _DosenLeaveScreenState();
}

class _DosenLeaveScreenState extends ConsumerState<DosenLeaveScreen> {
  int _selectedFilter = 0; // 0 = Sedang Berjalan, 1 = Sudah Lewat

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
                'Riwayat Izin & Cuti',
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
                        Icons.edit_document,
                        size: 130,
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
                            Icons.edit_document,
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      leave['type'].toString().replaceAll('_', ' '),
                                      style: TextStyle(
                                        color: isDark ? AppColors.accent : AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
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
                              const SizedBox(height: 10),
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
        padding: const EdgeInsets.only(bottom: 86.0),
        child: FloatingActionButton.extended(
          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          onPressed: () {
            showDialog(context: context, builder: (_) => const _AddLeaveDialog());
          },
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Buat Pengajuan', style: TextStyle(fontWeight: FontWeight.w700)),
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
  String selectedType = 'IZIN';
  DateTime? startDate;
  DateTime? endDate;
  final reasonController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (startDate ?? now) : (endDate ?? startDate ?? now),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tanggal mulai dan selesai')));
      return;
    }
    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alasan tidak boleh kosong')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/leaves', data: {
        'type': selectedType,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'reason': reasonController.text.trim(),
      });
      ref.invalidate(leaveRequestsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan izin berhasil dibuat'),
            backgroundColor: AppColors.statusHadir,
          ),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat: $msg')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Buat Pengajuan Izin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
              decoration: const InputDecoration(labelText: 'Tipe Izin'),
              items: const [
                DropdownMenuItem(value: 'IZIN', child: Text('Izin')),
                DropdownMenuItem(value: 'SAKIT', child: Text('Sakit')),
                DropdownMenuItem(value: 'CUTI', child: Text('Cuti')),
                DropdownMenuItem(value: 'DINAS_LUAR', child: Text('Dinas Luar')),
              ],
              onChanged: (val) => setState(() => selectedType = val!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _pickDate(true),
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Mulai Tanggal',
                  suffixIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
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
                  suffixIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                ),
                child: Text(endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : 'Pilih Tanggal'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Alasan Lengkap',
                alignLabelWithHint: true,
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
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
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
