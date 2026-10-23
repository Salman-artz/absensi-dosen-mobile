import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'schedule_provider.dart';
import '../master_data/master_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/report_exporter.dart';

class AdminScheduleScreen extends ConsumerWidget {
  const AdminScheduleScreen({super.key});

  String _getDayName(dynamic dayDynamic) {
    int day = int.tryParse(dayDynamic.toString()) ?? 0;
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    if (day >= 0 && day <= 6) return days[day];
    return 'Hari ke-$day';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsyncValue = ref.watch(scheduleListProvider);
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
                'Manajemen Jadwal',
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
                        Icons.edit_calendar_rounded,
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
            sliver: scheduleAsyncValue.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 70,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada jadwal kuliah',
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
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                courseName,
                                                style: TextStyle(
                                                  fontSize: 16,
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
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline_rounded,
                                              size: 16,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                s.lecturer?.name ?? 'Dosen Belum Diatur',
                                                style: TextStyle(
                                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 15,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _getDayName(s.dayOfWeek),
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 15,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}',
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.room_rounded, size: 15, color: AppColors.statusAlpa),
                                            const SizedBox(width: 6),
                                            Text(
                                              s.room?.name ?? '-',
                                              style: TextStyle(
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        const Divider(height: 1),
                                        const SizedBox(height: 8),

                                        // Actions Bar
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () => context.push('/class-students/${s.scheduleId}'),
                                                  icon: const Icon(Icons.group_rounded, size: 16),
                                                  label: const Text('Presensi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: isDark ? AppColors.accent : AppColors.primary,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.file_download_outlined, size: 18),
                                                  tooltip: 'Ekspor Rekap (PDF/Excel)',
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
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.statusTelat),
                                                  tooltip: 'Ubah Jadwal',
                                                  onPressed: () => showDialog(
                                                    context: context,
                                                    builder: (context) => EditScheduleDialog(schedule: s),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.qr_code_rounded,
                                                    size: 20,
                                                    color: isDark ? AppColors.accent : AppColors.primary,
                                                  ),
                                                  tooltip: 'QR Code',
                                                  onPressed: () => context.push('/generate-qr/${s.scheduleId}'),
                                                ),
                                              ],
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
          onPressed: () => _showAddScheduleDialog(context, ref),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddScheduleDialog(),
    );
  }
}

class AddScheduleDialog extends ConsumerStatefulWidget {
  const AddScheduleDialog({super.key});

  @override
  ConsumerState<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends ConsumerState<AddScheduleDialog> {
  String? selectedCourse;
  String? selectedLecturer;
  String? selectedRoom;
  String? dayOfWeek;
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  String? selectedClass;
  final semesterController = TextEditingController(text: 'Ganjil 2026/2027');

  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  bool isSubmitting = false;

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    semesterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final classText = selectedClass ?? '';
    if (selectedCourse == null ||
        selectedLecturer == null ||
        selectedRoom == null ||
        classText.isEmpty ||
        dayOfWeek == null ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi semua isian')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/schedules', data: {
        'courseId': selectedCourse,
        'lecturerId': selectedLecturer,
        'roomId': selectedRoom,
        'className': classText,
        'dayOfWeek': days.indexOf(dayOfWeek!) + 1,
        'startTime': startTimeController.text.trim(),
        'endTime': endTimeController.text.trim(),
        'semester': semesterController.text.trim(),
      });
      ref.invalidate(scheduleListProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menambah jadwal kuliah'),
          backgroundColor: AppColors.statusHadir,
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gagal menambah jadwal';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final lecturersAsync = ref.watch(lecturersProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final classesAsync = ref.watch(classesProvider);

    return AlertDialog(
      title: const Text('Tambah Jadwal Kuliah'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            coursesAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                value: selectedCourse,
                items: data.map((e) => DropdownMenuItem(value: e.courseId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedCourse = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            lecturersAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Dosen'),
                value: selectedLecturer,
                items: data.map((e) => DropdownMenuItem(value: e.userId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedLecturer = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            roomsAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ruang'),
                value: selectedRoom,
                items: data.map((e) => DropdownMenuItem(value: e.roomId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedRoom = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            classesAsync.when(
              data: (data) {
                final classNames = data.map((e) => e['className'].toString()).toSet().toList();
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Pilih Kelas'),
                  value: selectedClass,
                  items: classNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => selectedClass = v),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: semesterController,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hari'),
              value: dayOfWeek,
              items: days.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dayOfWeek = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Jam Mulai (HH:mm)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'Jam Selesai (HH:mm)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: isSubmitting ? null : _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class EditScheduleDialog extends ConsumerStatefulWidget {
  final dynamic schedule;
  const EditScheduleDialog({super.key, required this.schedule});

  @override
  ConsumerState<EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends ConsumerState<EditScheduleDialog> {
  String? selectedCourse;
  String? selectedLecturer;
  String? selectedRoom;
  String? dayOfWeek;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  String? selectedClass;
  late TextEditingController semesterController;

  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    selectedCourse = widget.schedule.course?.courseId;
    selectedLecturer = widget.schedule.lecturer?.userId;
    selectedRoom = widget.schedule.room?.roomId;

    int dayIndex = int.tryParse(widget.schedule.dayOfWeek.toString()) ?? 1;
    if (dayIndex >= 1 && dayIndex <= 7) {
      dayOfWeek = days[dayIndex - 1];
    }

    startTimeController = TextEditingController(text: widget.schedule.startTime);
    endTimeController = TextEditingController(text: widget.schedule.endTime);
    selectedClass = widget.schedule.className;
    semesterController = TextEditingController(text: widget.schedule.semester);
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    semesterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final classText = selectedClass ?? '';
    if (selectedCourse == null ||
        selectedLecturer == null ||
        selectedRoom == null ||
        classText.isEmpty ||
        dayOfWeek == null ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi semua isian')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/schedules/${widget.schedule.scheduleId}', data: {
        'courseId': selectedCourse,
        'lecturerId': selectedLecturer,
        'roomId': selectedRoom,
        'className': classText,
        'dayOfWeek': days.indexOf(dayOfWeek!) + 1,
        'startTime': startTimeController.text.trim(),
        'endTime': endTimeController.text.trim(),
        'semester': semesterController.text.trim(),
      });
      ref.invalidate(scheduleListProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil memperbarui jadwal'),
          backgroundColor: AppColors.statusHadir,
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gagal memperbarui jadwal';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final lecturersAsync = ref.watch(lecturersProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final classesAsync = ref.watch(classesProvider);

    return AlertDialog(
      title: const Text('Edit Jadwal Kuliah'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            coursesAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                value: data.any((c) => c.courseId == selectedCourse) ? selectedCourse : null,
                items: data.map((e) => DropdownMenuItem(value: e.courseId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedCourse = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            lecturersAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Dosen'),
                value: data.any((d) => d.userId == selectedLecturer) ? selectedLecturer : null,
                items: data.map((e) => DropdownMenuItem(value: e.userId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedLecturer = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            roomsAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ruang'),
                value: data.any((r) => r.roomId == selectedRoom) ? selectedRoom : null,
                items: data.map((e) => DropdownMenuItem(value: e.roomId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedRoom = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            classesAsync.when(
              data: (data) {
                final classNames = data.map((e) => e['className'].toString()).toSet().toList();
                if (selectedClass != null && !classNames.contains(selectedClass)) {
                  classNames.add(selectedClass!);
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Pilih Kelas'),
                  value: classNames.contains(selectedClass) ? selectedClass : null,
                  items: classNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => selectedClass = v),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error $e'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: semesterController,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hari'),
              value: dayOfWeek,
              items: days.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dayOfWeek = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Jam Mulai (HH:mm)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'Jam Selesai (HH:mm)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: isSubmitting ? null : _submit, child: const Text('Simpan')),
      ],
    );
  }
}
