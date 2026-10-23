import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';

class MeetingAttendanceScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const MeetingAttendanceScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingAttendanceScreen> createState() => _MeetingAttendanceScreenState();
}

class _MeetingAttendanceScreenState extends ConsumerState<MeetingAttendanceScreen> {
  bool isLoading = true;
  bool isSaving = false;
  List<Map<String, dynamic>> attendanceList = [];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendance() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/meetings/${widget.meetingId}/attendance');
      final list = res.data['data']['attendances'] as List<dynamic>;
      setState(() {
        attendanceList = list.map((e) => Map<String, dynamic>.from(e)).toList();
        isLoading = false;
      });
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        Navigator.pop(context);
      }
    }
  }

  void _markAll(String status) {
    setState(() {
      for (var item in attendanceList) {
        item['status'] = status;
      }
    });

    final label = status == 'HADIR' ? 'Hadir' : 'Tidak Hadir';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Semua mahasiswa ditandai $label. Tekan Simpan untuk konfirmasi.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveAttendance() async {
    setState(() => isSaving = true);
    try {
      final updates = attendanceList.map((a) => {
        'studentId': a['student']['id'],
        'status': a['status'],
      }).toList();

      final dio = ref.read(dioProvider);
      await dio.put('/meetings/${widget.meetingId}/attendance', data: {
        'updates': updates,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi berhasil disimpan ke server'),
            backgroundColor: AppColors.statusHadir,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.toString()),
            backgroundColor: AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _deleteMeeting() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pertemuan?'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan/menghapus pertemuan ini? Semua draf presensi di pertemuan ini akan hilang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAlpa),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/meetings/${widget.meetingId}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pertemuan berhasil dibatalkan')),
        );
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter by search query
    final filteredList = attendanceList.where((item) {
      if (searchQuery.isEmpty) return true;
      final name = (item['student']?['fullName'] ?? '').toString().toLowerCase();
      final nim = (item['student']?['nim'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || nim.contains(q);
    }).toList();

    // Stats calculations
    int hadirCount = 0;
    int sakitCount = 0;
    int izinCount = 0;
    int alpaCount = 0;

    for (var a in attendanceList) {
      switch (a['status']) {
        case 'HADIR':
          hadirCount++;
          break;
        case 'SAKIT':
          sakitCount++;
          break;
        case 'IZIN':
          izinCount++;
          break;
        default:
          alpaCount++;
          break;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Presensi Pertemuan'),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusAlpa),
              onPressed: _deleteMeeting,
              tooltip: 'Batalkan Pertemuan',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Summary & Bulk Action Panel
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Status Counter Pills
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBadge('Hadir', hadirCount, AppColors.statusHadir, isDark),
                          _buildStatBadge('Sakit', sakitCount, AppColors.statusTelat, isDark),
                          _buildStatBadge('Izin', izinCount, AppColors.statusIzin, isDark),
                          _buildStatBadge('Alpa', alpaCount, AppColors.statusAlpa, isDark),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Quick 1-Click Bulk Actions Bar
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _markAll('HADIR'),
                              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.statusHadir),
                              label: const Text(
                                'Tandai Semua Hadir',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.statusHadir,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.statusHadir, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => _markAll('TIDAK_HADIR'),
                            icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.textMuted),
                            label: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau NIM mahasiswa...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // Student Attendance List
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.isEmpty ? 'Tidak ada data mahasiswa' : 'Mahasiswa tidak ditemukan',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 90),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final attendance = filteredList[index];
                            final student = attendance['student'] ?? {};
                            final name = student['fullName'] ?? 'Nama Mahasiswa';
                            final nim = student['nim'] ?? '-';
                            final currentStatus = attendance['status'] ?? 'TIDAK_HADIR';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Initial Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: (isDark ? AppColors.primaryLight : AppColors.primary).withOpacity(0.12),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                      style: TextStyle(
                                        color: isDark ? AppColors.accent : AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Student Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'NIM: $nim',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Segmented Quick Status Pills: H, S, I, A
                                  _buildStatusPill('H', 'HADIR', currentStatus, AppColors.statusHadir, attendance),
                                  const SizedBox(width: 4),
                                  _buildStatusPill('S', 'SAKIT', currentStatus, AppColors.statusTelat, attendance),
                                  const SizedBox(width: 4),
                                  _buildStatusPill('I', 'IZIN', currentStatus, AppColors.statusIzin, attendance),
                                  const SizedBox(width: 4),
                                  _buildStatusPill('A', 'TIDAK_HADIR', currentStatus, AppColors.statusAlpa, attendance),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomSheet: !isLoading
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                    label: Text(
                      isSaving ? 'Menyimpan Presensi...' : 'Simpan Presensi Kelas',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatBadge(String title, int count, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(
    String label,
    String value,
    String currentStatus,
    Color activeColor,
    Map<String, dynamic> attendance,
  ) {
    final isSelected = currentStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          attendance['status'] = value;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
