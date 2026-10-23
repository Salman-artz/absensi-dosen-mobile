import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import 'master_provider.dart';

class CourseMasterScreen extends ConsumerWidget {
  const CourseMasterScreen({super.key});

  Future<void> _deleteCourse(BuildContext context, WidgetRef ref, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Yakin ingin menghapus mata kuliah "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAlpa),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/courses/$id');
      ref.invalidate(coursesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata kuliah berhasil dihapus')),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $msg')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Kelola Mata Kuliah')),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Text(
                'Belum ada mata kuliah',
                style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final c = courses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                    child: Text(
                      '${c.credits}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    '${c.code} - ${c.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${c.credits} SKS',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.statusTelat, size: 20),
                        onPressed: () => showDialog(context: context, builder: (_) => _EditCourseDialog(course: c)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.statusAlpa, size: 20),
                        onPressed: () => _deleteCourse(context, ref, c.courseId, c.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => showDialog(context: context, builder: (_) => const _AddCourseDialog()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Matkul', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _AddCourseDialog extends ConsumerStatefulWidget {
  const _AddCourseDialog();
  @override
  ConsumerState<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends ConsumerState<_AddCourseDialog> {
  final codeCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final sksCtrl = TextEditingController(text: '3');
  bool isSubmitting = false;

  @override
  void dispose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    sksCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = codeCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final sks = int.tryParse(sksCtrl.text.trim()) ?? 0;

    if (code.isEmpty || name.isEmpty || sks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi kode, nama, dan SKS')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/courses', data: {
        'code': code,
        'name': name,
        'sks': sks,
      });
      ref.invalidate(coursesProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mata kuliah berhasil ditambahkan')));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Mata Kuliah'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kode (misal: CS101)')),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Mata Kuliah')),
          const SizedBox(height: 12),
          TextField(
            controller: sksCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah SKS'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: isSubmitting ? null : _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class _EditCourseDialog extends ConsumerStatefulWidget {
  final dynamic course;
  const _EditCourseDialog({required this.course});
  @override
  ConsumerState<_EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends ConsumerState<_EditCourseDialog> {
  late TextEditingController codeCtrl;
  late TextEditingController nameCtrl;
  late TextEditingController sksCtrl;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    codeCtrl = TextEditingController(text: widget.course.code);
    nameCtrl = TextEditingController(text: widget.course.name);
    sksCtrl = TextEditingController(text: '${widget.course.credits}');
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    sksCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = codeCtrl.text.trim();
    final name = nameCtrl.text.trim();
    final sks = int.tryParse(sksCtrl.text.trim()) ?? 0;

    if (code.isEmpty || name.isEmpty || sks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi kode, nama, dan SKS')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/courses/${widget.course.courseId}', data: {
        'code': code,
        'name': name,
        'sks': sks,
      });
      ref.invalidate(coursesProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mata kuliah berhasil diubah')));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah Mata Kuliah'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kode')),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Mata Kuliah')),
          const SizedBox(height: 12),
          TextField(
            controller: sksCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah SKS'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(onPressed: isSubmitting ? null : _submit, child: const Text('Simpan')),
      ],
    );
  }
}
