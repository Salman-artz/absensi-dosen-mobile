import '../models/qr_session.dart';

abstract class AttendanceRepository {
  Future<QrSession> generateSession(String scheduleId);
  Future<Map<String, dynamic>> scanAttendance(String token);
}
