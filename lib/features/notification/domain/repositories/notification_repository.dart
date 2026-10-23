abstract class NotificationRepository {
  Future<List<dynamic>> getNotifications();
  Future<void> markAsRead(String id);
}
