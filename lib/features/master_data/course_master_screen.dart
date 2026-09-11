import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';
import 'master_provider.dart';

class CourseMasterScreen extends ConsumerWidget {
  const CourseMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Mata Kuliah')),
      body: coursesAsync.when(
        data: (courses) {
          if (courses.isEmpty) return const Center(child: Text('Belum ada mata kuliah'));
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final c = courses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text('${c.code} - ${c.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${c.credits} SKS'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => showDialog(context: context, builder: (_) => _EditCourseDialog(course: c)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(context: context, builder: (_) => const _AddCourseDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteCourse(BuildContext context, WidgetRef ref, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text('Yakin ingin menghapus mata kuliah $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
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
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil dihapus')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }
}

class _AddCourseDialog extends ConsumerStatefulWidget {
  const _AddCourseDialog();
  @override
  ConsumerState<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends ConsumerState<_AddCourseDialog> {
  final codeController = TextEditingController();
  final nameController = TextEditingController();
  final sksController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submit() async {
    final sks = int.tryParse(sksController.text);
    if (codeController.text.isEmpty || nameController.text.isEmpty || sks == null) return;
    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/courses', data: {'code': codeController.text, 'name': nameController.text, 'sks': sks});
      ref.invalidate(coursesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Matkul'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Kode (misal: IF301)')),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Matkul')),
          TextField(controller: sksController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SKS')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        isSubmitting ? const CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class _EditCourseDialog extends ConsumerStatefulWidget {
  final Course course;
  const _EditCourseDialog({required this.course});
  @override
  ConsumerState<_EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends ConsumerState<_EditCourseDialog> {
  late TextEditingController codeController;
  late TextEditingController nameController;
  late TextEditingController sksController;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.course.code);
    nameController = TextEditingController(text: widget.course.name);
    sksController = TextEditingController(text: widget.course.credits.toString());
  }

  Future<void> _submit() async {
    final sks = int.tryParse(sksController.text);
    if (codeController.text.isEmpty || nameController.text.isEmpty || sks == null) return;
    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/courses/${widget.course.courseId}', data: {'code': codeController.text, 'name': nameController.text, 'sks': sks});
      ref.invalidate(coursesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Matkul'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Kode (misal: IF301)')),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Matkul')),
          TextField(controller: sksController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SKS')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        isSubmitting ? const CircularProgressIndicator() : ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
