import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

final notificationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/notifications');
  return res.data['data'];
});

final unreadCountProvider = Provider.autoDispose<int>((ref) {
  final notifs = ref.watch(notificationsProvider).valueOrNull;
  if (notifs == null) return 0;
  return notifs.where((n) => n['isRead'] == false).length;
});
