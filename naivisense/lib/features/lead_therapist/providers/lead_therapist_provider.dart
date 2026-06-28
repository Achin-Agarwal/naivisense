import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/child.dart';
import '../../../data/models/concern.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/concerns_repository.dart';

final ltChildrenProvider = FutureProvider<List<ChildModel>>(
  (ref) => ref.read(childrenRepositoryProvider).getChildren(),
);

// Lead therapist sees all open concerns across all children
final ltAllOpenConcernsProvider =
    FutureProvider.family<List<ConcernModel>, String>((ref, childId) =>
        ref.read(concernsRepositoryProvider).getConcerns(
              childId: childId,
              status: 'open',
            ));

// ── Resolve Concern state ─────────────────────────────────────────────────

class ResolveConcernState {
  final bool loading;
  final String? error;
  final bool success;
  const ResolveConcernState(
      {this.loading = false, this.error, this.success = false});
  ResolveConcernState copyWith(
          {bool? loading, String? error, bool? success}) =>
      ResolveConcernState(
        loading: loading ?? this.loading,
        error:   error,
        success: success ?? this.success,
      );
}

class ResolveConcernNotifier extends Notifier<ResolveConcernState> {
  @override
  ResolveConcernState build() => const ResolveConcernState();

  Future<bool> resolve(
      String id, String childId, String resolution) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(concernsRepositoryProvider).resolveConcern(
            id,
            resolution: resolution,
          );
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(ltAllOpenConcernsProvider(childId));
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final resolveConcernProvider =
    NotifierProvider<ResolveConcernNotifier, ResolveConcernState>(
        ResolveConcernNotifier.new);
