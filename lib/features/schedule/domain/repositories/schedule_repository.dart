import '../models/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getAllSchedules();
  Future<List<Schedule>> getMySchedules();
  Future<List<dynamic>> getClasses();
  Future<void> createSchedule(Map<String, dynamic> data);
  Future<void> updateSchedule(String id, Map<String, dynamic> data);
}
