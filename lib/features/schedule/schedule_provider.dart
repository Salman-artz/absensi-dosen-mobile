import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';

final scheduleListProvider = FutureProvider.autoDispose<List<Schedule>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/schedules');
  final List data = res.data['data'];
  return data.map((e) => Schedule.fromJson(e)).toList();
});

final myScheduleListProvider = FutureProvider.autoDispose<List<Schedule>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/schedules/me');
  final List data = res.data['data'];
  return data.map((e) => Schedule.fromJson(e)).toList();
});

final classesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/students/classes');
  return res.data['data'] as List<dynamic>;
});
