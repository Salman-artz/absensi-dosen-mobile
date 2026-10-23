import 'package:dio/dio.dart';
import '../domain/models/course.dart';
import '../domain/models/room.dart';
import '../domain/repositories/master_repository.dart';
import '../../auth/domain/models/user.dart';

class MasterRepositoryImpl implements MasterRepository {
  final Dio _dio;

  MasterRepositoryImpl(this._dio);

  @override
  Future<List<Course>> getCourses() async {
    final res = await _dio.get('/courses');
    final List data = res.data['data'] ?? [];
    return data.map((e) => Course.fromJson(e)).toList();
  }

  @override
  Future<void> createCourse(String code, String name, int sks) async {
    await _dio.post('/courses', data: {
      'code': code,
      'name': name,
      'sks': sks,
    });
  }

  @override
  Future<void> updateCourse(String id, String code, String name, int sks) async {
    await _dio.put('/courses/$id', data: {
      'code': code,
      'name': name,
      'sks': sks,
    });
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _dio.delete('/courses/$id');
  }

  @override
  Future<List<Room>> getRooms() async {
    final res = await _dio.get('/rooms');
    final List data = res.data['data'] ?? [];
    return data.map((e) => Room.fromJson(e)).toList();
  }

  @override
  Future<void> createRoom(String name, String? building) async {
    await _dio.post('/rooms', data: {
      'name': name,
      'building': building,
    });
  }

  @override
  Future<List<User>> getLecturers() async {
    final res = await _dio.get('/users', queryParameters: {'role': 'DOSEN'});
    final List data = res.data['data'] ?? [];
    return data.map((e) => User.fromJson(e)).toList();
  }

  @override
  Future<void> createLecturer(String name, String email, String password, String? nip) async {
    await _dio.post('/users', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': 'DOSEN',
      'nip': nip,
    });
  }
}
