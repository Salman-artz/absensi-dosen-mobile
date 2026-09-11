import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class MeetingAttendanceScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const MeetingAttendanceScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingAttendanceScreen> createState() => _MeetingAttendanceScreenState();
}

class _MeetingAttendanceScreenState extends ConsumerState<MeetingAttendanceScreen> {
  bool isLoading = true;
  bool isSaving = false;
  List<dynamic> attendanceList = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/meetings/${widget.meetingId}/attendance');
      setState(() {
        attendanceList = res.data['data']['attendances'];
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveAttendance() async {
    setState(() => isSaving = true);
    try {
      final updates = attendanceList.map((a) => {
        'studentId': a['student']['id'],
        'status': a['status'],
      }).toList();

      final dio = ref.read(dioProvider);
      await dio.put('/meetings/${widget.meetingId}/attendance', data: {
        'updates': updates,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Presensi berhasil disimpan')));
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _deleteMeeting() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pertemuan?'),
        content: const Text('Apakah Anda yakin ingin membatalkan/menghapus pertemuan ini? Semua draf presensi di pertemuan ini akan hilang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('/meetings/${widget.meetingId}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pertemuan dibatalkan')));
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isi Presensi Manual'),
        actions: [
          if (!isLoading)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent), 
              onPressed: _deleteMeeting,
              tooltip: 'Batalkan Pertemuan',
            ),
          if (!isLoading)
            isSaving
                ? const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.white))
                : IconButton(icon: const Icon(Icons.save), onPressed: _saveAttendance),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final attendance = attendanceList[index];
                final student = attendance['student'];
                final status = attendance['status'];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(student['fullName'] ?? '-'),
                    subtitle: Text(student['nim'] ?? '-'),
                    trailing: DropdownButton<String>(
                      value: status,
                      items: ['HADIR', 'TIDAK_HADIR', 'SAKIT', 'IZIN']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' '))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            attendance['status'] = val;
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
