import 'package:dio/dio.dart';
import '../domain/models/qr_session.dart';
import '../domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final Dio _dio;

  AttendanceRepositoryImpl(this._dio);

  @override
  Future<QrSession> generateSession(String scheduleId) async {
    final res = await _dio.post('/attendance/sessions', data: {
      'scheduleId': scheduleId,
    });
    return QrSession.fromJson(res.data['data']);
  }

  @override
  Future<Map<String, dynamic>> scanAttendance(String token) async {
    final res = await _dio.post('/attendance/scan', data: {
      'token': token,
    });
    return res.data['data'];
  }
}
