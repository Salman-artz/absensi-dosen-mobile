import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'domain/repositories/leave_repository.dart';
import 'data/leave_repository_impl.dart';

export 'domain/models/leave_request.dart';
export 'domain/repositories/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LeaveRepositoryImpl(dio);
});

final leaveRequestsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(leaveRepositoryProvider);
  return repo.getLeaveRequests();
});
