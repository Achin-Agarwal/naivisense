import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/concern.dart';

final concernsRepositoryProvider = Provider<ConcernsRepository>(
  (ref) => ConcernsRepository(ref.read(apiServiceProvider)),
);

class ConcernsRepository {
  final ApiService _api;
  ConcernsRepository(this._api);

  Future<List<ConcernModel>> getConcerns({required String childId, String? status}) async {
    try {
      final params = <String, String>{'childId': childId};
      if (status != null) params['status'] = status;
      final res  = await _api.get('/concerns', params: params);
      final list = res.data as List<dynamic>;
      return list.map((e) => ConcernModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ConcernModel> createConcern(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/concerns', data: data);
      return ConcernModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ConcernModel> resolveConcern(String id, {required String resolution}) async {
    try {
      final res = await _api.patch('/concerns/$id', data: {
        'status': 'resolved',
        'resolution': resolution,
      });
      return ConcernModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
