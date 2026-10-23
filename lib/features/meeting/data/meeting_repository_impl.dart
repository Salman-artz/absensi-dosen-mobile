import 'package:dio/dio.dart';
import '../domain/models/meeting.dart';
import '../domain/repositories/meeting_repository.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  final Dio _dio;

  MeetingRepositoryImpl(this._dio);

  @override
  Future<Meeting> openMeeting(String scheduleId, int meetingNumber) async {
    final res = await _dio.post('/meetings', data: {
      'scheduleId': scheduleId,
      'meetingNumber': meetingNumber,
    });
    return Meeting.fromJson(res.data['data']);
  }

  @override
  Future<List<StudentAttendanceItem>> getMeetingAttendance(String meetingId) async {
    final res = await _dio.get('/meetings/$meetingId/attendance');
    final List attendances = res.data['data']['attendances'] ?? [];
    return attendances.map((e) => StudentAttendanceItem.fromJson(e)).toList();
  }

  @override
  Future<void> saveAttendance(String meetingId, List<StudentAttendanceItem> items) async {
    final updates = items.map((e) => e.toUpdateJson()).toList();
    await _dio.put('/meetings/$meetingId/attendance', data: {
      'updates': updates,
    });
  }

  @override
  Future<void> deleteMeeting(String meetingId) async {
    await _dio.delete('/meetings/$meetingId');
  }

  @override
  Future<Map<String, dynamic>> getMeetingRecap(String scheduleId) async {
    final res = await _dio.get('/meetings/recap/$scheduleId');
    return res.data['data'] ?? {};
  }
}
