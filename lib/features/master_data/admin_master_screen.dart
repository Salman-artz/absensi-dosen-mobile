import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import 'master_provider.dart';
import 'course_master_screen.dart';

class AdminMasterScreen extends ConsumerWidget {
  const AdminMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              title: const Text('Data Master', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 24, letterSpacing: -0.5)),
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
                      child: Icon(Icons.storage_rounded, size: 140, color: Colors.white.withOpacity(0.15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context,
                  'Kelola Dosen',
                  'Tambah data dosen dan akun akses dosen baru.',
                  Icons.person_add_alt_1_rounded,
                  () => showDialog(context: context, builder: (_) => const _AddDosenDialog()),
                ),
                _buildMenuCard(
                  context,
                  'Kelola Mata Kuliah',
                  'Daftar mata kuliah, kurikulum, dan SKS.',
                  Icons.menu_book_rounded,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseMasterScreen())),
                ),
                _buildMenuCard(
                  context,
                  'Kelola Ruangan',
                  'Daftar ruang kelas dan laboratorium kampus.',
                  Icons.meeting_room_rounded,
                  () => showDialog(context: context, builder: (_) => const _AddRoomDialog()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2E3192).withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FAFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, size: 32, color: const Color(0xFF2E3192)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2E3192))),
                      const SizedBox(height: 6),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade600, height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== DIALOG TAMBAH DOSEN ====================
class _AddDosenDialog extends ConsumerStatefulWidget {
  const _AddDosenDialog();
  @override
  ConsumerState<_AddDosenDialog> createState() => _AddDosenDialogState();
}

class _AddDosenDialogState extends ConsumerState<_AddDosenDialog> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nipController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submit() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama, Email, dan Password wajib diisi')));
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/users', data: {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'role': 'DOSEN',
        'nip': nipController.text.isEmpty ? null : nipController.text,
      });
      ref.invalidate(lecturersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosen berhasil ditambahkan')));
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
      title: const Text('Tambah Dosen Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
            TextField(controller: nipController, decoration: const InputDecoration(labelText: 'NIP (Opsional)')),
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


class _AddRoomDialog extends ConsumerStatefulWidget {
  const _AddRoomDialog();
  @override
  ConsumerState<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends ConsumerState<_AddRoomDialog> {
  final nameController = TextEditingController();
  final buildingController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submit() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Ruang wajib diisi')));
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/rooms', data: {
        'name': nameController.text,
        'building': buildingController.text.isEmpty ? null : buildingController.text,
      });
      ref.invalidate(roomsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruang berhasil ditambahkan')));
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
      title: const Text('Tambah Ruangan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Ruang (misal: Lab B)')),
            TextField(controller: buildingController, decoration: const InputDecoration(labelText: 'Gedung (Opsional)')),
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
