import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/courses');
  final List data = res.data['data'];
  return data.map((e) => Course.fromJson(e)).toList();
});

final roomsProvider = FutureProvider.autoDispose<List<Room>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/rooms');
  final List data = res.data['data'];
  return data.map((e) => Room.fromJson(e)).toList();
});

final lecturersProvider = FutureProvider.autoDispose<List<User>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/users', queryParameters: {'role': 'DOSEN'});
  final List data = res.data['data'];
  return data.map((e) => User.fromJson(e)).toList();
});
