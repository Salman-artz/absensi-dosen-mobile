abstract class LeaveRepository {
  Future<List<dynamic>> getLeaveRequests();
  Future<void> createLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  });
  Future<void> updateLeaveStatus(String leaveId, String status);
}
