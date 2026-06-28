import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/alert.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>(
  (ref) => AlertsRepository(ref.read(apiServiceProvider)),
);

class AlertsRepository {
  final ApiService _api;
  AlertsRepository(this._api);

  Future<List<AlertModel>> getAlerts(String childId) async {
    try {
      final res = await _api.get('/alerts', params: {'childId': childId});
      final list = res.data as List<dynamic>;
      return list.map((e) => AlertModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AlertModel> createAlert(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/alerts', data: data);
      return AlertModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AlertModel> resolveAlert(String id, {required String resolutionNote}) async {
    try {
      final res = await _api.patch('/alerts/$id', data: {
        'status': 'resolved',
        'resolution_note': resolutionNote,
      });
      return AlertModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
