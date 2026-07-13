import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/session.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>(
  (ref) => SessionsRepository(ref.read(apiServiceProvider)),
);

class SessionsRepository {
  final ApiService _api;
  SessionsRepository(this._api);

  // For therapist home — returns upcoming sessions without requiring childId
  Future<List<SessionModel>> getUpcoming() async {
    try {
      final res = await _api.get('/sessions/upcoming');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  // For child-specific view — childId required by backend
  Future<List<SessionModel>> getSessions({required String childId}) async {
    try {
      final res = await _api.get('/sessions', params: {'childId': childId});
      final list = res.data as List<dynamic>;
      return list
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> updateSession(
    String sessionId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _api.patch(
        '/session-timings/$sessionId',
        data: payload,
      );

      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> createSession(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/sessions', data: data);
      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> submitNotes(
    String sessionId,
    Map<String, dynamic> notes,
  ) async {
    try {
      final res = await _api.post('/sessions/$sessionId/notes', data: notes);
      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> updateNotes(
    String sessionId,
    Map<String, dynamic> notes,
  ) async {
    try {
      final res = await _api.put('/sessions/$sessionId/notes', data: notes);

      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel?> getNextSession({required String childId}) async {
    try {
      final res = await _api.get(
        '/sessions/next',
        params: {'childId': childId},
      );
      if (res.data == null) return null;
      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
