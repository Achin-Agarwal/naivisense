import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/review.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/alerts_repository.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/diet_plans_repository.dart';
import '../../../data/repositories/goals_repository.dart';
import '../../../data/repositories/home_plans_repository.dart';
import '../../../data/repositories/reviews_repository.dart';
import '../../../data/repositories/sessions_repository.dart';
import '../../../data/repositories/videos_repository.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../../../data/repositories/payments_repository.dart';
import '../../../data/models/video_item.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/payment.dart';

final parentChildrenProvider = FutureProvider<List<ChildModel>>(
  (ref) => ref.read(childrenRepositoryProvider).getChildren(),
);

final parentActivePlanProvider =
    FutureProvider.family<HomePlanModel?, String>((ref, childId) =>
        ref.read(homePlansRepositoryProvider).getActivePlan(childId));

final parentDietPlanProvider =
    FutureProvider.family<DietPlanModel?, String>((ref, childId) =>
        ref.read(dietPlansRepositoryProvider).getActivePlan(childId));

final parentSessionsProvider =
    FutureProvider.family<List<SessionModel>, String>((ref, childId) =>
        ref.read(sessionsRepositoryProvider).getSessions(childId: childId));

final parentAlertsProvider =
    FutureProvider.family<List<AlertModel>, String>((ref, childId) =>
        ref.read(alertsRepositoryProvider).getAlerts(childId));

final parentGoalsProvider =
    FutureProvider.family<List<GoalModel>, String>((ref, childId) =>
        ref.read(goalsRepositoryProvider).getGoals(childId: childId));

final parentReviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, childId) =>
        ref.read(reviewsRepositoryProvider).getReviews(childId: childId));

final parentVideosProvider =
    FutureProvider.family<List<VideoItemModel>, String>((ref, childId) =>
        ref.read(videosRepositoryProvider).getVideos(childId: childId));

final parentPaymentsProvider = FutureProvider<List<PaymentModel>>(
  (ref) => ref.read(paymentsRepositoryProvider).getPayments(),
);

final parentChatThreadProvider = FutureProvider<ChatThreadModel>(
  (ref) => ref.read(chatbotRepositoryProvider).getOrCreateThread(),
);

final parentChatMessagesProvider = FutureProvider.family<List<ChatMessageModel>, String>(
  (ref, threadId) => ref.read(chatbotRepositoryProvider).getMessages(threadId),
);

// ── Chat send state ────────────────────────────────────────────────────────

class ChatSendState {
  final bool loading;
  final String? error;
  const ChatSendState({this.loading = false, this.error});
}

class ChatSendNotifier extends Notifier<ChatSendState> {
  @override
  ChatSendState build() => const ChatSendState();

  Future<ChatMessageModel?> send(String threadId, String message) async {
    state = const ChatSendState(loading: true);
    try {
      final msg = await ref.read(chatbotRepositoryProvider).sendMessage(threadId, message);
      state = const ChatSendState();
      ref.invalidate(parentChatMessagesProvider(threadId));
      return msg;
    } catch (e) {
      state = ChatSendState(error: e.toString());
      return null;
    }
  }
}

final chatSendProvider =
    NotifierProvider<ChatSendNotifier, ChatSendState>(ChatSendNotifier.new);

// ── Task log state ─────────────────────────────────────────────────────────

class TaskLogState {
  final bool loading;
  final String? error;
  final bool success;
  const TaskLogState({this.loading = false, this.error, this.success = false});
  TaskLogState copyWith({bool? loading, String? error, bool? success}) =>
      TaskLogState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class TaskLogNotifier extends Notifier<TaskLogState> {
  @override
  TaskLogState build() => const TaskLogState();

  Future<bool> logTask({
    required String planId,
    required String taskId,
    String note = 'Completed',
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(homePlansRepositoryProvider).logTask(
            planId: planId,
            taskId: taskId,
            note:   note,
          );
      state = state.copyWith(loading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final taskLogProvider = NotifierProvider<TaskLogNotifier, TaskLogState>(TaskLogNotifier.new);

// ── Alert creation state ───────────────────────────────────────────────────

class AlertState {
  final bool loading;
  final String? error;
  final bool success;
  const AlertState({this.loading = false, this.error, this.success = false});
  AlertState copyWith({bool? loading, String? error, bool? success}) =>
      AlertState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class AlertNotifier extends Notifier<AlertState> {
  @override
  AlertState build() => const AlertState();

  Future<bool> submit(Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(alertsRepositoryProvider).createAlert(payload);
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(parentAlertsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final alertProvider = NotifierProvider<AlertNotifier, AlertState>(AlertNotifier.new);

// ── Video upload state ─────────────────────────────────────────────────────

class VideoUploadState {
  final bool loading;
  final String? error;
  final bool success;
  const VideoUploadState({this.loading = false, this.error, this.success = false});
  VideoUploadState copyWith({bool? loading, String? error, bool? success}) =>
      VideoUploadState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class VideoUploadNotifier extends Notifier<VideoUploadState> {
  @override
  VideoUploadState build() => const VideoUploadState();

  Future<bool> upload({
    required String childId,
    required String title,
    required String filePath,
    required String mimeType,
  }) async {
    state = state.copyWith(loading: true, error: null, success: false);
    try {
      await ref.read(videosRepositoryProvider).uploadVideo(
        childId:    childId,
        title:      title,
        category:   'parent_observation',
        filePath:   filePath,
        mimeType:   mimeType,
        visibility: 'internal',
      );
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(parentVideosProvider(childId));
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final videoUploadProvider =
    NotifierProvider<VideoUploadNotifier, VideoUploadState>(VideoUploadNotifier.new);
