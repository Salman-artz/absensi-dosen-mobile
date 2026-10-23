import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';

class ScanAbsenScreen extends ConsumerStatefulWidget {
  const ScanAbsenScreen({super.key});

  @override
  ConsumerState<ScanAbsenScreen> createState() => _ScanAbsenScreenState();
}

class _ScanAbsenScreenState extends ConsumerState<ScanAbsenScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  bool isTorchOn = false;

  Future<void> _handleScan(String rawValue) async {
    if (!isScanning) return;
    setState(() => isScanning = false);

    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/attendance/scan', data: {
        'token': rawValue,
      });

      final status = res.data['data']['status']; // HADIR or TELAT
      final isHadir = status == 'HADIR';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  isHadir ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: isHadir ? AppColors.statusHadir : AppColors.statusTelat,
                ),
                const SizedBox(width: 10),
                const Text('Presensi Berhasil'),
              ],
            ),
            content: Text(
              'Status kehadiran Anda berhasil dicatat sebagai $status.',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHadir ? AppColors.statusHadir : AppColors.statusTelat,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(90, 42),
                ),
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close scan screen
                },
                child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
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
        errMsg = 'QR Code sudah kedaluwarsa.';
      } else {
        errMsg = e.response?.data?['message'] ?? e.message ?? errMsg;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: AppColors.statusAlpa,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Allow scanning again after 2 seconds
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
      appBar: AppBar(
        title: const Text('Pindai QR Presensi'),
        actions: [
          IconButton(
            tooltip: 'Senter',
            icon: Icon(isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            onPressed: () {
              setState(() => isTorchOn = !isTorchOn);
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            tooltip: 'Ganti Kamera',
            icon: const Icon(Icons.flip_camera_ios_rounded),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _handleScan(barcodes.first.rawValue!);
              }
            },
          ),

          // Viewfinder Target Overlay
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryLight,
                width: 3,
              ),
            ),
          ),

          // Bottom Instruction Pill
          Positioned(
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Arahkan kamera ke QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
