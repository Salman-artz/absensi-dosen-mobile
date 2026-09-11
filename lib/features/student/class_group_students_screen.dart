import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

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
      setState(() {
        students = res.data['data'];
        isLoading = false;
      });
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
      builder: (context) => AlertDialog(
        title: const Text('Tambah Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nimCtrl, decoration: const InputDecoration(labelText: 'NIM')),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nimCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                final dio = ref.read(dioProvider);
                await dio.post('/students/classes/${widget.className}/${Uri.encodeComponent(widget.semester)}/students', data: {
                  'nim': nimCtrl.text,
                  'fullName': nameCtrl.text,
                });
                _fetchStudents();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mahasiswa ditambahkan')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                setState(() => isLoading = false);
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
      builder: (context) => AlertDialog(
        title: const Text('Edit Mahasiswa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nimCtrl, decoration: const InputDecoration(labelText: 'NIM')),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nimCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
              Navigator.pop(context);
              setState(() => isLoading = true);
              try {
                final dio = ref.read(dioProvider);
                await dio.put('/students/$studentId', data: {
                  'nim': nimCtrl.text,
                  'fullName': nameCtrl.text,
                });
                _fetchStudents();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mahasiswa diupdate')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                setState(() => isLoading = false);
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
      builder: (context) => AlertDialog(
        title: const Text('Hapus Mahasiswa?'),
        content: Text('Keluarkan $name dari seluruh jadwal kelas ${widget.className}?'),
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
    setState(() => isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/students/classes/${widget.className}/${Uri.encodeComponent(widget.semester)}/students/$studentId');
      _fetchStudents();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mahasiswa dihapus')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahasiswa ${widget.className}'),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : students.isEmpty
          ? const Center(child: Text('Belum ada mahasiswa'))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(s['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(s['nim']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editStudentDialog(s['id'], s['nim'], s['fullName']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(s['id'], s['fullName']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudentDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
