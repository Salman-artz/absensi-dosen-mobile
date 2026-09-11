import 'package:flutter/material.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Mahasiswa')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Pilih Pertemuan (1-16) dan tandai status Hadir/Sakit/Izin/Alpha'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Mahasiswa ${index + 1}'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'HADIR', label: Text('H')),
                      ButtonSegment(value: 'SAKIT', label: Text('S')),
                      ButtonSegment(value: 'IZIN', label: Text('I')),
                      ButtonSegment(value: 'ALPHA', label: Text('A')),
                    ],
                    selected: const {'ALPHA'},
                    onSelectionChanged: (set) {
                      // Update status
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // POST /api/meetings/:id/attendance
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
