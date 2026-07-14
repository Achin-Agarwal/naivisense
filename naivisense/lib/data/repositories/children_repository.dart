import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/child.dart';

final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) => ChildrenRepository(ref.read(apiServiceProvider)),
);

class ChildrenRepository {
  final ApiService _api;
  ChildrenRepository(this._api);

  Future<List<ChildModel>> getChildren() async {
    try {
      final res = await _api.get('/children');
      final list = res.data as List<dynamic>;
      return list.map((e) {
        try {
          return ChildModel.fromJson(e as Map<String, dynamic>);
        } catch (err, st) {
          rethrow;
        }
      }).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ChildModel> getChild(String id) async {
    try {
      final res = await _api.get('/children/$id');
      return ChildModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ChildModel> createChild(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/children', data: data);
      return ChildModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ChildModel> updateChild(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/children/$id', data: data);
      return ChildModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
