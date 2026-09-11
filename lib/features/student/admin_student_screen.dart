import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import '../schedule/schedule_provider.dart';
import 'add_class_dialog.dart';

class AdminStudentScreen extends ConsumerWidget {
  const AdminStudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ClassListTab();
  }
}

class _ClassListTab extends ConsumerStatefulWidget {
  const _ClassListTab();

  @override
  ConsumerState<_ClassListTab> createState() => _ClassListTabState();
}

class _ClassListTabState extends ConsumerState<_ClassListTab> {
  bool isLoading = true;
  List<dynamic> classes = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/students/classes');
      if (mounted) {
        setState(() {
          classes = res.data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text('Grup Kelas & Mahasiswa', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 20, letterSpacing: -0.5)),
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
                      child: Icon(Icons.group_rounded, size: 140, color: Colors.white.withOpacity(0.15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
            sliver: _buildListContent(),
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
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AddClassDialog(onSuccess: _fetchClasses),
            );
          },
          icon: const Icon(Icons.group_add_rounded),
          label: const Text('Tambah Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildListContent() {
    if (isLoading) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
    if (classes.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off_rounded, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Belum ada grup kelas', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final c = classes[index];
          final safeSemester = Uri.encodeComponent(c['semester']);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2E3192).withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  context.push('/class-group-students/${c['className']}/$safeSemester').then((_) => _fetchClasses());
                },
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
                                radius: 24,
                                child: const Icon(Icons.people_alt_rounded),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kelas ${c['className']}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF2E3192)),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      c['semester'],
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('${c['totalStudents']} Mahasiswa', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: const Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
                                onPressed: () => _editClass(c['className'], c['semester']),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () => _deleteClass(c['className'], c['semester']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: classes.length,
      ),
    );
  }

  Future<void> _editClass(String oldName, String oldSem) async {
    final nameCtrl = TextEditingController(text: oldName);
    final semCtrl = TextEditingController(text: oldSem);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Grup Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama Kelas', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: semCtrl, decoration: InputDecoration(labelText: 'Semester', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E3192), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || semCtrl.text.isEmpty) return;
              Navigator.pop(context);
              try {
                final dio = ref.read(dioProvider);
                await dio.put('/students/classes/$oldName/${Uri.encodeComponent(oldSem)}', data: {
                  'newClassName': nameCtrl.text,
                  'newSemester': semCtrl.text,
                });
                _fetchClasses();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas diupdate')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClass(String name, String sem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Grup Kelas?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text('PERHATIAN: Menghapus grup $name akan menghapus SELURUH JADWAL matkul untuk kelas ini, beserta seluruh data riwayat presensinya! Yakin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/students/classes/$name/${Uri.encodeComponent(sem)}');
      _fetchClasses();
      ref.invalidate(scheduleListProvider); // jadwal juga terhapus, perlu refresh
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas beserta seluruh jadwalnya dihapus')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }
}
