import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'data/dashboard_repository_impl.dart';

export 'domain/models/dashboard_data.dart';
export 'domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepositoryImpl(dio);
});

final dashboardSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getSummary();
});

final dashboardRekapProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getRekap();
});
