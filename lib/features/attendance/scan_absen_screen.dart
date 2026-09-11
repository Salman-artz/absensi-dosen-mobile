import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class ScanAbsenScreen extends ConsumerStatefulWidget {
  const ScanAbsenScreen({super.key});

  @override
  ConsumerState<ScanAbsenScreen> createState() => _ScanAbsenScreenState();
}

class _ScanAbsenScreenState extends ConsumerState<ScanAbsenScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  Future<void> _handleScan(String rawValue) async {
    if (!isScanning) return;
    setState(() => isScanning = false);

    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/attendance/scan', data: {
        'token': rawValue,
      });

      final status = res.data['data']['status']; // HADIR or LATE
      final isHadir = status == 'HADIR';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Berhasil Absen', style: TextStyle(color: isHadir ? Colors.green : Colors.orange)),
            content: Text('Status kehadiran Anda dicatat sebagai $status.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close screen
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      String errMsg = 'Gagal melakukan absen.';
      if (code == 403) {
        errMsg = 'Anda bukan pengampu kelas ini.';
      } else if (code == 409) {
        errMsg = 'Anda sudah melakukan absen.';
      } else if (code == 410) {
        errMsg = 'QR Code sudah expired.';
      } else {
        errMsg = e.response?.data?['message'] ?? e.message ?? errMsg;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg)));
        // Allow scanning again after failure
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => isScanning = true);
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Absensi')),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            _handleScan(barcodes.first.rawValue!);
          }
        },
      ),
    );
  }
}
