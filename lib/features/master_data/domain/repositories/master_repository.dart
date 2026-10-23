import '../models/course.dart';
import '../models/room.dart';
import 'package:absensi_dosen_mobile/features/auth/domain/models/user.dart';

abstract class MasterRepository {
  Future<List<Course>> getCourses();
  Future<void> createCourse(String code, String name, int sks);
  Future<void> updateCourse(String id, String code, String name, int sks);
  Future<void> deleteCourse(String id);

  Future<List<Room>> getRooms();
  Future<void> createRoom(String name, String? building);

  Future<List<User>> getLecturers();
  Future<void> createLecturer(String name, String email, String password, String? nip);
}
