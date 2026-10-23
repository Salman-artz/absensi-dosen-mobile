import '../models/meeting.dart';

abstract class MeetingRepository {
  Future<Meeting> openMeeting(String scheduleId, int meetingNumber);
  Future<List<StudentAttendanceItem>> getMeetingAttendance(String meetingId);
  Future<void> saveAttendance(String meetingId, List<StudentAttendanceItem> items);
  Future<void> deleteMeeting(String meetingId);
  Future<Map<String, dynamic>> getMeetingRecap(String scheduleId);
}
