import '../models/student.dart';

abstract class StudentRepository {
  Future<List<ClassGroup>> getClasses();
  Future<List<Student>> getStudentsByClass(String className, String semester);
  Future<void> addStudentToClass(String className, String semester, String nim, String fullName);
  Future<void> updateStudent(String studentId, String nim, String fullName);
  Future<void> deleteStudent(String className, String semester, String studentId);
  Future<void> updateClass(String oldName, String oldSem, String newName, String newSem);
  Future<void> deleteClass(String name, String sem);
}
