import 'package:dio/dio.dart';
import '../domain/models/schedule.dart';
import '../domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final Dio _dio;

  ScheduleRepositoryImpl(this._dio);

  @override
  Future<List<Schedule>> getAllSchedules() async {
    final res = await _dio.get('/schedules');
    final List data = res.data['data'] ?? [];
    return data.map((e) => Schedule.fromJson(e)).toList();
  }

  @override
  Future<List<Schedule>> getMySchedules() async {
    final res = await _dio.get('/schedules/me');
    final List data = res.data['data'] ?? [];
    return data.map((e) => Schedule.fromJson(e)).toList();
  }

  @override
  Future<List<dynamic>> getClasses() async {
    final res = await _dio.get('/students/classes');
    return res.data['data'] as List<dynamic>;
  }

  @override
  Future<void> createSchedule(Map<String, dynamic> data) async {
    await _dio.post('/schedules', data: data);
  }

  @override
  Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
    await _dio.put('/schedules/$id', data: data);
  }
}
