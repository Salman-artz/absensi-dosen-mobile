import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';

class ClassGroupStudentsScreen extends ConsumerStatefulWidget {
  final String className;
  final String semester;
  const ClassGroupStudentsScreen({super.key, required this.className, required this.semester});

  @override
  ConsumerState<ClassGroupStudentsScreen> createState() => _ClassGroupStudentsScreenState();
}

class _ClassGroupStudentsScreenState extends ConsumerState<ClassGroupStudentsScreen> {
  bool isLoading = true;
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/students/classes/${widget.className}/${Uri.encodeComponent(widget.semester)}/students');
      if (mounted) {
        setState(() {
          students = res.data['data'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addStudentDialog() async {
    final nimCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nimCtrl, decoration: const InputDecoration(labelText: 'NIM')),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final nim = nimCtrl.text.trim();
              final name = nameCtrl.text.trim();
              if (nim.isEmpty || name.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => isLoading = true);
              try {
                final dio = ref.read(dioProvider);
                await dio.post(
                  '/students/classes/${widget.className}/${Uri.encodeComponent(widget.semester)}/students',
                  data: {'nim': nim, 'fullName': name},
                );
                _fetchStudents();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mahasiswa berhasil ditambahkan')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  setState(() => isLoading = false);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _editStudentDialog(String studentId, String currentNim, String currentName) async {
    final nimCtrl = TextEditingController(text: currentNim);
    final nameCtrl = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nimCtrl, decoration: const InputDecoration(labelText: 'NIM')),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final nim = nimCtrl.text.trim();
              final name = nameCtrl.text.trim();
              if (nim.isEmpty || name.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => isLoading = true);
              try {
                final dio = ref.read(dioProvider);
                await dio.put('/students/$studentId', data: {'nim': nim, 'fullName': name});
                _fetchStudents();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mahasiswa berhasil diperbarui')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  setState(() => isLoading = false);
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(String studentId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Mahasiswa?'),
        content: Text('Keluarkan $name dari seluruh jadwal kelas ${widget.className}?'),
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
    setState(() => isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete(
        '/students/classes/${widget.className}/${Uri.encodeComponent(widget.semester)}/students/$studentId',
      );
      _fetchStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mahasiswa berhasil dikeluarkan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Mahasiswa Kelas ${widget.className}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada mahasiswa terdaftar',
                    style: TextStyle(color: isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final name = s['fullName'] ?? '-';
                    final nim = s['nim'] ?? '-';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
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
                            radius: 20,
                            backgroundColor: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'M',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.statusTelat, size: 18),
                            onPressed: () => _editStudentDialog(s['id'], nim, name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.statusAlpa, size: 18),
                            onPressed: () => _deleteStudent(s['id'], name),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _addStudentDialog,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Mahasiswa', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
