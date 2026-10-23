import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import 'master_provider.dart';
import 'course_master_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';

class AdminMasterScreen extends ConsumerWidget {
  const AdminMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                'Data Master',
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
                        Icons.storage_rounded,
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
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context,
                  'Kelola Dosen',
                  'Tambah data dosen dan akun akses dosen baru.',
                  Icons.person_add_alt_1_rounded,
                  () => showDialog(context: context, builder: (_) => const _AddDosenDialog()),
                  isDark,
                ),
                _buildMenuCard(
                  context,
                  'Kelola Mata Kuliah',
                  'Daftar mata kuliah, kurikulum, dan SKS.',
                  Icons.menu_book_rounded,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseMasterScreen())),
                  isDark,
                ),
                _buildMenuCard(
                  context,
                  'Kelola Ruangan',
                  'Daftar ruang kelas dan laboratorium kampus.',
                  Icons.meeting_room_rounded,
                  () => showDialog(context: context, builder: (_) => const _AddRoomDialog()),
                  isDark,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 28, color: isDark ? AppColors.accent : AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nipController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama, Email, dan Password wajib diisi')));
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/users', data: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'role': 'DOSEN',
        'nip': nipController.text.trim().isEmpty ? null : nipController.text.trim(),
      });
      ref.invalidate(lecturersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosen berhasil ditambahkan'),
            backgroundColor: AppColors.statusHadir,
          ),
        );
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
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Kampus')),
            const SizedBox(height: 12),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            TextField(controller: nipController, decoration: const InputDecoration(labelText: 'NIP (Opsional)')),
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

class _AddRoomDialog extends ConsumerStatefulWidget {
  const _AddRoomDialog();
  @override
  ConsumerState<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends ConsumerState<_AddRoomDialog> {
  final nameController = TextEditingController();
  final buildingController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    nameController.dispose();
    buildingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama Ruang wajib diisi')));
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/rooms', data: {
        'name': nameController.text.trim(),
        'building': buildingController.text.trim().isEmpty ? null : buildingController.text.trim(),
      });
      ref.invalidate(roomsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruang berhasil ditambahkan'),
            backgroundColor: AppColors.statusHadir,
          ),
        );
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
            const SizedBox(height: 12),
            TextField(controller: buildingController, decoration: const InputDecoration(labelText: 'Gedung (Opsional)')),
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
