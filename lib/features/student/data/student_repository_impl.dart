import 'package:dio/dio.dart';
import '../domain/models/student.dart';
import '../domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final Dio _dio;

  StudentRepositoryImpl(this._dio);

  @override
  Future<List<ClassGroup>> getClasses() async {
    final res = await _dio.get('/students/classes');
    final List list = res.data['data'] ?? [];
    return list.map((e) => ClassGroup.fromJson(e)).toList();
  }

  @override
  Future<List<Student>> getStudentsByClass(String className, String semester) async {
    final res = await _dio.get(
      '/students/classes/$className/${Uri.encodeComponent(semester)}/students',
    );
    final List list = res.data['data'] ?? [];
    return list.map((e) => Student.fromJson(e)).toList();
  }

  @override
  Future<void> addStudentToClass(String className, String semester, String nim, String fullName) async {
    await _dio.post(
      '/students/classes/$className/${Uri.encodeComponent(semester)}/students',
      data: {'nim': nim, 'fullName': fullName},
    );
  }

  @override
  Future<void> updateStudent(String studentId, String nim, String fullName) async {
    await _dio.put('/students/$studentId', data: {'nim': nim, 'fullName': fullName});
  }

  @override
  Future<void> deleteStudent(String className, String semester, String studentId) async {
    await _dio.delete(
      '/students/classes/$className/${Uri.encodeComponent(semester)}/students/$studentId',
    );
  }

  @override
  Future<void> updateClass(String oldName, String oldSem, String newName, String newSem) async {
    await _dio.put(
      '/students/classes/$oldName/${Uri.encodeComponent(oldSem)}',
      data: {
        'newClassName': newName,
        'newSemester': newSem,
      },
    );
  }

  @override
  Future<void> deleteClass(String name, String sem) async {
    await _dio.delete('/students/classes/$name/${Uri.encodeComponent(sem)}');
  }
}
