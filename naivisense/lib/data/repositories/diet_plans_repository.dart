import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/diet_plan.dart';

final dietPlansRepositoryProvider = Provider<DietPlansRepository>(
  (ref) => DietPlansRepository(ref.read(apiServiceProvider)),
);

class DietPlansRepository {
  final ApiService _api;
  DietPlansRepository(this._api);

  Future<DietPlanModel?> getActivePlan(String childId) async {
    try {
      final res = await _api.get('/diet-plans/active', params: {'childId': childId});
      return DietPlanModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      final ex = ErrorHandlerService.handle(e);
      if (ex.code == 'NOT_FOUND' || ex.code == 'FORBIDDEN') return null;
      throw ex;
    }
  }

  Future<DietPlanModel> createPlan(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/diet-plans', data: data);
      return DietPlanModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
