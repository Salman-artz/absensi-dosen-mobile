import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:absensi_dosen_mobile/core/api/api_client.dart';
import 'package:absensi_dosen_mobile/features/master_data/domain/models/course.dart';
import 'package:absensi_dosen_mobile/features/master_data/domain/models/room.dart';
import 'package:absensi_dosen_mobile/features/auth/domain/models/user.dart';
import 'package:absensi_dosen_mobile/features/master_data/domain/repositories/master_repository.dart';
import 'package:absensi_dosen_mobile/features/master_data/data/master_repository_impl.dart';

final masterRepositoryProvider = Provider<MasterRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MasterRepositoryImpl(dio);
});

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final repo = ref.watch(masterRepositoryProvider);
  return repo.getCourses();
});

final roomsProvider = FutureProvider.autoDispose<List<Room>>((ref) async {
  final repo = ref.watch(masterRepositoryProvider);
  return repo.getRooms();
});

final lecturersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final repo = ref.watch(masterRepositoryProvider);
  return repo.getLecturers();
});
