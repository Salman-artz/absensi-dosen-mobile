import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/models/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../data/schedule_repository_impl.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleRepositoryImpl(dio);
});

final scheduleListProvider = FutureProvider.autoDispose<List<Schedule>>((ref) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getAllSchedules();
});

final myScheduleListProvider = FutureProvider.autoDispose<List<Schedule>>((ref) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getMySchedules();
});

final classesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getClasses();
});
