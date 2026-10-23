abstract class DashboardRepository {
  Future<Map<String, dynamic>> getSummary();
  Future<List<dynamic>> getRekap();
}
