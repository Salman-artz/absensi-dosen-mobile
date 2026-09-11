import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('QR Absensi')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (qrToken != null)
                    QrImageView(
                      data: qrToken!,
                      version: QrVersions.auto,
                      size: 250.0,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    _remainingSeconds > 0
                        ? 'Berlaku selama: ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}'
                        : 'QR Expired!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
