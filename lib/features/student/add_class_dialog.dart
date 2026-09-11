import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // import kIsWeb
import '../../core/api/api_client.dart';

class AddClassDialog extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const AddClassDialog({super.key, required this.onSuccess});

  @override
  ConsumerState<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends ConsumerState<AddClassDialog> {
  int _selectedIndex = 0; // 0 = Manual, 1 = Import Excel

  // Manual Controllers
  final nameCtrl = TextEditingController();
  final semCtrl = TextEditingController(text: 'Ganjil 2026/2027');
  final nimCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();

  // Excel Variables
  String? _filePath;
  Uint8List? _fileBytes;
  String? _fileName;
  Map<String, dynamic>? _previewData;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _fileBytes = result.files.single.bytes;
        _filePath = kIsWeb ? null : result.files.single.path;
        _fileName = result.files.single.name;
        _previewData = null; 
        _errorMessage = null;
      });
      _getPreview();
    }
  }

  Future<void> _getPreview() async {
    if ((_filePath == null && _fileBytes == null) || semCtrl.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = ref.read(dioProvider);
      MultipartFile fileToUpload;
      if (_fileBytes != null) {
        fileToUpload = MultipartFile.fromBytes(_fileBytes!, filename: _fileName);
      } else {
        fileToUpload = await MultipartFile.fromFile(_filePath!, filename: _fileName);
      }

      final formData = FormData.fromMap({
        'semester': semCtrl.text,
        'file': fileToUpload,
      });

      final res = await dio.post('/students/preview-import', data: formData);
      setState(() {
        _previewData = res.data['data'];
        _errorMessage = null;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage = 'Gagal preview (API Error): ${e.response?.statusCode} - ${e.response?.data?['message'] ?? e.message}';
        _filePath = null;
        _fileBytes = null;
        _fileName = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memproses file: $e';
        _filePath = null;
        _fileBytes = null;
        _fileName = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (semCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semester terlebih dahulu')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      
      if (_selectedIndex == 0) {
        // Manual
        if (nameCtrl.text.isEmpty || nimCtrl.text.isEmpty || fullNameCtrl.text.isEmpty) {
          throw Exception('Isi semua field');
        }
        await dio.post('/students/classes/${nameCtrl.text}/${Uri.encodeComponent(semCtrl.text)}/students', data: {
          'nim': nimCtrl.text,
          'fullName': fullNameCtrl.text,
        });
      } else {
        // Excel
        if ((_filePath == null && _fileBytes == null) || _previewData == null) {
          throw Exception('Pilih file Excel terlebih dahulu');
        }
        MultipartFile fileToUpload;
        if (_fileBytes != null) {
          fileToUpload = MultipartFile.fromBytes(_fileBytes!, filename: _fileName);
        } else {
          fileToUpload = await MultipartFile.fromFile(_filePath!, filename: _fileName);
        }

        final formData = FormData.fromMap({
          'semester': semCtrl.text,
          'file': fileToUpload,
        });

        await dio.post('/students/import', data: formData);
      }
      
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kelas berhasil ditambahkan!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Kelas Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Manual')),
                ButtonSegment(value: 1, label: Text('Import Excel')),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => _selectedIndex = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            TextField(controller: semCtrl, decoration: const InputDecoration(labelText: 'Semester (Wajib)')),
            const SizedBox(height: 16),
            if (_selectedIndex == 0) ...[
              const Text('Masukkan 1 mahasiswa pertama di kelas ini:'),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Kelas (mis: TI-3A)')),
              TextField(controller: nimCtrl, decoration: const InputDecoration(labelText: 'NIM Mahasiswa')),
              TextField(controller: fullNameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Mahasiswa')),
            ] else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.file_upload),
                label: Text(_fileName ?? 'Pilih File Excel (.xlsx)'),
                onPressed: _isLoading ? null : _pickFile,
              ),
              if (_isLoading) const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator())),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade50,
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
              if (_previewData != null && !_isLoading) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preview Data:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Total Data: ${_previewData!['totalRows']} Mahasiswa'),
                      Text('Deteksi Kelas: ${_previewData!['sampleClass']}'),
                      const Divider(),
                      const Text('Contoh Data:'),
                      ...(_previewData!['sampleData'] as List).map((e) => Text('- ${e['nim']} : ${e['name']}')),
                    ],
                  ),
                ),
              ],
            ]
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _isLoading || (_selectedIndex == 1 && _previewData == null) ? null : _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
