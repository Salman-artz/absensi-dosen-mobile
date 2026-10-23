import 'package:dio/dio.dart';
import '../domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final Dio _dio;

  LeaveRepositoryImpl(this._dio);

  @override
  Future<List<dynamic>> getLeaveRequests() async {
    final res = await _dio.get('/leave-requests');
    return res.data['data'] as List<dynamic>;
  }

  @override
  Future<void> createLeaveRequest({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await _dio.post('/leaves', data: {
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    });
  }

  @override
  Future<void> updateLeaveStatus(String leaveId, String status) async {
    await _dio.patch('/leaves/$leaveId/status', data: {
      'status': status,
    });
  }
}
