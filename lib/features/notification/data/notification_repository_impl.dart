import 'package:dio/dio.dart';
import '../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl(this._dio);

  @override
  Future<List<dynamic>> getNotifications() async {
    final res = await _dio.get('/notifications');
    return res.data['data'] as List<dynamic>;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.patch('/notifications/$id/read');
  }
}
