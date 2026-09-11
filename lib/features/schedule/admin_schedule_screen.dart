import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'schedule_provider.dart';
import '../auth/auth_provider.dart';
import '../master_data/master_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';

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
              title: const Text('Manajemen Jadwal', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 24, letterSpacing: -0.5)),
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
                      child: Icon(Icons.edit_calendar_rounded, size: 140, color: Colors.white.withOpacity(0.15)),
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
                          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Belum ada jadwal', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold)),
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
                                            const Icon(Icons.person_rounded, size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text(s.lecturer?.name ?? '-', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
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
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.room_rounded, size: 18, color: Colors.redAccent),
                                            const SizedBox(width: 8),
                                            Text(s.room?.name ?? '-', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () => context.push('/class-students/${s.scheduleId}'),
                                              icon: const Icon(Icons.group_rounded, color: Colors.blueAccent),
                                              label: const Text('Mahasiswa', style: TextStyle(color: Colors.blueAccent)),
                                            ),
                                            TextButton.icon(
                                              onPressed: () {
                                                showDialog(context: context, builder: (context) => EditScheduleDialog(schedule: s));
                                              },
                                              icon: const Icon(Icons.edit_rounded, color: Colors.orange),
                                              label: const Text('Edit', style: TextStyle(color: Colors.orange)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.qr_code_rounded, color: Color(0xFF2E3192)),
                                              tooltip: 'Generate QR',
                                              onPressed: () => context.push('/generate-qr/${s.scheduleId}'),
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
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2E3192),
          foregroundColor: Colors.white,
          elevation: 8,
          onPressed: () {
            _showAddScheduleDialog(context, ref);
          },
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Tambah Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _submit() async {
    final classText = selectedClass ?? '';
    if (selectedCourse == null || selectedLecturer == null || selectedRoom == null ||
        classText.isEmpty || dayOfWeek == null || startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty || semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi form')));
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
        'startTime': startTimeController.text,
        'endTime': endTimeController.text,
        'semester': semesterController.text,
      });
      ref.invalidate(scheduleListProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambah jadwal')));
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
      title: const Text('Tambah Jadwal'),
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
              error: (e,s) => Text('Error $e'),
            ),
            lecturersAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Dosen'),
                value: selectedLecturer,
                items: data.map((e) => DropdownMenuItem(value: e.userId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedLecturer = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e,s) => Text('Error $e'),
            ),
            roomsAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ruang'),
                value: selectedRoom,
                items: data.map((e) => DropdownMenuItem(value: e.roomId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedRoom = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e,s) => Text('Error $e'),
            ),
            classesAsync.when(
              data: (data) {
                final classNames = data.map((e) => e['className'].toString()).toSet().toList();
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Pilih Kelas'),
                  value: classNames.contains(selectedClass) ? selectedClass : null,
                  items: classNames.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => selectedClass = v),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e,s) => Text('Error $e'),
            ),
            TextField(
              controller: semesterController,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hari'),
              value: dayOfWeek,
              items: days.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dayOfWeek = v),
            ),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Jam Mulai (HH:MM)'),
            ),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'Jam Selesai (HH:MM)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        isSubmitting ? const CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class EditScheduleDialog extends ConsumerStatefulWidget {
  final Schedule schedule;
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
    
    int dayIndex = int.tryParse(widget.schedule.dayOfWeek) ?? 1;
    if (dayIndex >= 1 && dayIndex <= 7) {
      dayOfWeek = days[dayIndex - 1];
    }
    
    startTimeController = TextEditingController(text: widget.schedule.startTime);
    endTimeController = TextEditingController(text: widget.schedule.endTime);
    selectedClass = widget.schedule.className;
    semesterController = TextEditingController(text: widget.schedule.semester);
  }

  Future<void> _submit() async {
    final classText = selectedClass ?? '';
    if (selectedCourse == null || selectedLecturer == null || selectedRoom == null ||
        classText.isEmpty || dayOfWeek == null || startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty || semesterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap lengkapi form')));
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
        'startTime': startTimeController.text,
        'endTime': endTimeController.text,
        'semester': semesterController.text,
      });
      ref.invalidate(scheduleListProvider);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil mengupdate jadwal')));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Gagal mengupdate jadwal';
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
      title: const Text('Edit Jadwal'),
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
              error: (e,s) => Text('Error $e'),
            ),
            lecturersAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Dosen'),
                value: data.any((d) => d.userId == selectedLecturer) ? selectedLecturer : null,
                items: data.map((e) => DropdownMenuItem(value: e.userId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedLecturer = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e,s) => Text('Error $e'),
            ),
            roomsAsync.when(
              data: (data) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ruang'),
                value: data.any((r) => r.roomId == selectedRoom) ? selectedRoom : null,
                items: data.map((e) => DropdownMenuItem(value: e.roomId, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => selectedRoom = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e,s) => Text('Error $e'),
            ),
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
              error: (e,s) => Text('Error $e'),
            ),
            TextField(
              controller: semesterController,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Hari'),
              value: dayOfWeek,
              items: days.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => dayOfWeek = v),
            ),
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(labelText: 'Jam Mulai (HH:MM)'),
            ),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(labelText: 'Jam Selesai (HH:MM)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        isSubmitting ? const CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
