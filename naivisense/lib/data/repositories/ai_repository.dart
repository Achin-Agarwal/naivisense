import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/ai_draft.dart';

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepository(ref.read(apiServiceProvider)),
);

class AiRepository {
  final ApiService _api;
  AiRepository(this._api);

  Future<AiDraftModel> generateTherapyPlan(String childId) async {
    try {
      final res = await _api.post('/ai/therapy-plan', data: {'child_id': childId});
      return AiDraftModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AiDraftModel> generateHomePlan(String childId) async {
    try {
      final res = await _api.post('/ai/home-plan', data: {'child_id': childId});
      return AiDraftModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AiDraftModel> generateDietSummary(String childId) async {
    try {
      final res = await _api.post('/ai/diet-summary', data: {'child_id': childId});
      return AiDraftModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AiDraftModel> generateReinforcementActivities(String childId) async {
    try {
      final res = await _api.post('/ai/reinforcement-activities', data: {'child_id': childId});
      return AiDraftModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AiDraftModel> generateInsights(String childId) async {
    try {
      final res = await _api.post('/ai/insights-v2', data: {'child_id': childId});
      return AiDraftModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<AiDraftModel>> listDrafts(String childId) async {
    try {
      final res  = await _api.get('/ai/drafts', params: {'child_id': childId});
      final list = res.data as List<dynamic>;
      return list.map((e) => AiDraftModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<AiDraftModel> approveDraft(String draftId) async {
    try {
      final res = await _api.patch('/ai/drafts/$draftId/approve', data: {});
      return AiDraftModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
