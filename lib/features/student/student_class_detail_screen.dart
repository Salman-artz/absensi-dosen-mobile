import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class StudentClassDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const StudentClassDetailScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<StudentClassDetailScreen> createState() => _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends ConsumerState<StudentClassDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? recapData;

  @override
  void initState() {
    super.initState();
    _fetchRecap();
  }

  Future<void> _fetchRecap() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/meetings/recap/${widget.scheduleId}');
      setState(() {
        recapData = res.data['data'];
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _downloadAndOpenExcel(String courseName) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunduh Excel...')));
      final dio = ref.read(dioProvider);
      
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/Rekap_${courseName.replaceAll(' ', '_')}.xlsx';
      
      await dio.download('/reports/attendance/${widget.scheduleId}/excel', filePath);
      
      await OpenFilex.open(filePath);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal unduh: $msg')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal buka file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Kelas')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (recapData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Kelas')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final schedule = recapData!['schedule'];
    final rows = recapData!['rows'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text('${schedule['course']['name']} (${schedule['className']})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart, color: Colors.green),
            tooltip: 'Export Excel',
            onPressed: () => _downloadAndOpenExcel(schedule['course']['name']),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dosen: ${schedule['lecturer']['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Total Pertemuan Digelar: ${recapData!['totalMeetings']}'),
                const SizedBox(height: 4),
                Text('Total Mahasiswa: ${rows.length}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                final student = row['student'];
                final percent = row['hadirPercent'];

                Color percentColor = Colors.green;
                if (percent < 75) percentColor = Colors.red;
                else if (percent < 85) percentColor = Colors.orange;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: percentColor.withOpacity(0.2),
                      child: Text('${percent.round()}%', style: TextStyle(color: percentColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(student['fullName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(student['nim']),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('H:${row['hadir']} A:${row['tidakHadir']}', style: const TextStyle(fontSize: 12)),
                        Text('S:${row['sakit']} I:${row['izin']}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
