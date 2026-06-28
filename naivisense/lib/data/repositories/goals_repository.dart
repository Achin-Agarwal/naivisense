import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/goal.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => GoalsRepository(ref.read(apiServiceProvider)),
);

class GoalsRepository {
  final ApiService _api;
  GoalsRepository(this._api);

  Future<List<GoalModel>> getGoals({required String childId}) async {
    try {
      final res  = await _api.get('/goals', params: {'childId': childId});
      final list = res.data as List<dynamic>;
      return list.map((e) => GoalModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<GoalModel> createGoal(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/goals', data: data);
      return GoalModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/goals/$id', data: data);
      return GoalModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
