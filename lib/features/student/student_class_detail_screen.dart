import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/report_exporter.dart';

class StudentClassDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const StudentClassDetailScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<StudentClassDetailScreen> createState() => _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends ConsumerState<StudentClassDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? recapData;

  @override
  void initState() {
    super.initState();
    _fetchRecap();
  }

  Future<void> _fetchRecap() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/meetings/recap/${widget.scheduleId}');
      setState(() {
        recapData = res.data['data'];
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Presensi Kelas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recapData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Presensi Kelas')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final schedule = recapData!['schedule'];
    final rows = recapData!['rows'] as List;
    final courseName = schedule['course']?['name'] ?? 'Mata Kuliah';
    final className = schedule['className'] ?? '-';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('$courseName ($className)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Ekspor Rekap (PDF/Excel)',
            onPressed: () {
              final dio = ref.read(dioProvider);
              ReportExporter.showExportBottomSheet(
                context: context,
                dio: dio,
                scheduleId: widget.scheduleId,
                courseName: courseName,
                className: className,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengampu: ${schedule['lecturer']?['name'] ?? '-'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: ${rows.length} Mahasiswa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pertemuan Digelar: ${recapData!['totalMeetings']} dari 16 pertemuan',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Mahasiswa Attendance List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                final student = row['student'];
                final num percent = row['hadirPercent'] ?? 0;

                Color percentColor = AppColors.statusHadir;
                if (percent < 75) {
                  percentColor = AppColors.statusAlpa;
                } else if (percent < 85) {
                  percentColor = AppColors.statusTelat;
                }

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
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: percentColor.withOpacity(isDark ? 0.2 : 0.12),
                        child: Text(
                          '${percent.round()}%',
                          style: TextStyle(
                            color: percentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['fullName'] ?? '-',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIM: ${student['nim'] ?? '-'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMiniBadge('H: ${row['hadir']}', AppColors.statusHadir),
                              const SizedBox(width: 4),
                              _buildMiniBadge('A: ${row['tidakHadir']}', AppColors.statusAlpa),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMiniBadge('S: ${row['sakit']}', AppColors.statusTelat),
                              const SizedBox(width: 4),
                              _buildMiniBadge('I: ${row['izin']}', AppColors.statusIzin),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
