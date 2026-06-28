import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/child.dart';
import '../../../data/models/concern.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/concerns_repository.dart';
import '../../../data/repositories/videos_repository.dart';

final cpChildrenProvider = FutureProvider<List<ChildModel>>(
  (ref) => ref.read(childrenRepositoryProvider).getChildren(),
);

final cpChildConcernsProvider =
    FutureProvider.family<List<ConcernModel>, String>((ref, childId) =>
        ref.read(concernsRepositoryProvider).getConcerns(childId: childId));

// ── Raise Concern state ────────────────────────────────────────────────────

class RaiseConcernState {
  final bool loading;
  final String? error;
  final bool success;
  const RaiseConcernState({this.loading = false, this.error, this.success = false});
  RaiseConcernState copyWith({bool? loading, String? error, bool? success}) =>
      RaiseConcernState(
        loading: loading ?? this.loading,
        error:   error,
        success: success ?? this.success,
      );
}

class RaiseConcernNotifier extends Notifier<RaiseConcernState> {
  @override
  RaiseConcernState build() => const RaiseConcernState();

  Future<ConcernModel?> submit(Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final concern = await ref.read(concernsRepositoryProvider).createConcern(payload);
      state = state.copyWith(loading: false, success: true);
      return concern;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<bool> submitWithVideo({
    required Map<String, dynamic> payload,
    required String childId,
    required String videoTitle,
    required String videoPath,
    required String mimeType,
  }) async {
    final concern = await submit(payload);
    if (concern == null) return false;
    try {
      await ref.read(videosRepositoryProvider).uploadVideo(
        childId:         childId,
        title:           videoTitle,
        category:        'clinical_observation',
        filePath:        videoPath,
        mimeType:        mimeType,
        visibility:      'internal',
        linkedConcernId: concern.id,
      );
    } catch (_) {
      // concern created; video upload failure is non-fatal
    }
    return true;
  }
}

final raiseConcernProvider =
    NotifierProvider<RaiseConcernNotifier, RaiseConcernState>(
        RaiseConcernNotifier.new);
