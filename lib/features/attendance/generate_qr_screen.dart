import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import 'dart:async';

class GenerateQrScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const GenerateQrScreen({super.key, required this.scheduleId});

  @override
  ConsumerState<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends ConsumerState<GenerateQrScreen> {
  bool isLoading = true;
  String? qrToken;
  DateTime? expiresAt;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _generateSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateSession() async {
    setState(() => isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/attendance/sessions', data: {
        'scheduleId': widget.scheduleId,
      });
      final data = res.data['data'];
      setState(() {
        qrToken = data['token'];
        expiresAt = DateTime.parse(data['expiresAt']);
        isLoading = false;
      });
      _startCountdown();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
        Navigator.pop(context);
      }
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (expiresAt == null) return;
    final now = DateTime.now();
    final diff = expiresAt!.difference(now).inSeconds;
    if (diff <= 0) {
      _timer?.cancel();
      if (mounted) setState(() => _remainingSeconds = 0);
    } else {
      if (mounted) setState(() => _remainingSeconds = diff);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = _remainingSeconds <= 0 && !isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('QR Code Presensi'),
        actions: [
          IconButton(
            tooltip: 'Buat Token Baru',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: isLoading ? null : _generateSession,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Instruction Banner
              Text(
                'Tampilkan ke Mahasiswa / Dosen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pindai QR ini melalui kamera aplikasi untuk mencatat presensi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // QR Code Card Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, // Always white background for QR readability
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.accent.withOpacity(0.3) : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : qrToken != null
                        ? Opacity(
                            opacity: isExpired ? 0.3 : 1.0,
                            child: QrImageView(
                              data: qrToken!,
                              version: QrVersions.auto,
                              size: 240.0,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF1E1B4B),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          )
                        : const SizedBox(
                            width: 240,
                            height: 240,
                            child: Center(child: Text('Gagal membuat QR')),
                          ),
              ),
              const SizedBox(height: 28),

              // Countdown / Expired Badge
              if (!isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? AppColors.statusAlpa.withOpacity(0.12)
                        : AppColors.statusHadir.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isExpired ? AppColors.statusAlpa : AppColors.statusHadir,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
                        color: isExpired ? AppColors.statusAlpa : AppColors.statusHadir,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        !isExpired
                            ? 'Berlaku: ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}'
                            : 'QR Code Kedaluwarsa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isExpired ? AppColors.statusAlpa : AppColors.statusHadir,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isExpired) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _generateSession,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Perbarui QR Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    minimumSize: const Size(220, 48),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
