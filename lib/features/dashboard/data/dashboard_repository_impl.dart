import 'package:dio/dio.dart';
import '../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getSummary() async {
    final res = await _dio.get('/dashboard/summary');
    return res.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<List<dynamic>> getRekap() async {
    final res = await _dio.get('/dashboard/rekap');
    return res.data['data'] as List<dynamic>;
  }
}
