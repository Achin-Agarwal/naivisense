import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/diet_request.dart';

final dietRequestsRepositoryProvider = Provider<DietRequestsRepository>(
  (ref) => DietRequestsRepository(ref.read(apiServiceProvider)),
);

class DietRequestsRepository {
  final ApiService _api;
  DietRequestsRepository(this._api);

  Future<List<DietRequestModel>> getDietRequests({String? childId}) async {
    try {
      final params = <String, dynamic>{};
      if (childId != null) params['childId'] = childId;
      final res  = await _api.get('/diet-requests', params: params);
      final list = res.data as List<dynamic>;
      return list
          .map((e) => DietRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<DietRequestModel> createDietRequest(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/diet-requests', data: data);
      return DietRequestModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<DietRequestModel> updateDietRequest(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/diet-requests/$id', data: data);
      return DietRequestModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
