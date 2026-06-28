import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/chat_message.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>(
  (ref) => ChatbotRepository(ref.read(apiServiceProvider)),
);

class ChatbotRepository {
  final ApiService _api;
  ChatbotRepository(this._api);

  Future<ChatThreadModel> getOrCreateThread({String? childId}) async {
    try {
      final res = await _api.post('/chatbot/thread', data: {
        'child_id': ?childId,
      });
      return ChatThreadModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<ChatThreadModel>> listThreads() async {
    try {
      final res  = await _api.get('/chatbot');
      final list = res.data as List<dynamic>;
      return list.map((e) => ChatThreadModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<ChatMessageModel>> getMessages(String threadId) async {
    try {
      final res  = await _api.get('/chatbot/thread/$threadId/messages');
      final list = res.data as List<dynamic>;
      return list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<ChatMessageModel> sendMessage(String threadId, String message) async {
    try {
      final res = await _api.post('/chatbot/thread/$threadId/messages', data: {'message': message});
      return ChatMessageModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<void> closeThread(String threadId) async {
    try {
      await _api.patch('/chatbot/thread/$threadId/close', data: {});
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
