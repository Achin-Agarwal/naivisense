import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/diet_request.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/diet_plans_repository.dart';
import '../../../data/repositories/diet_requests_repository.dart';

final dieticianChildrenProvider = FutureProvider<List<ChildModel>>(
  (ref) => ref.read(childrenRepositoryProvider).getChildren(),
);

final dieticianRequestsProvider = FutureProvider<List<DietRequestModel>>(
  (ref) => ref.read(dietRequestsRepositoryProvider).getDietRequests(),
);

final dieticianChildDietPlanProvider =
    FutureProvider.family<DietPlanModel?, String>((ref, childId) =>
        ref.read(dietPlansRepositoryProvider).getActivePlan(childId));

// ── Create Diet Request state ──────────────────────────────────────────────

class DietRequestState {
  final bool loading;
  final String? error;
  final bool success;
  const DietRequestState({this.loading = false, this.error, this.success = false});
  DietRequestState copyWith({bool? loading, String? error, bool? success}) =>
      DietRequestState(
        loading: loading ?? this.loading,
        error:   error,
        success: success ?? this.success,
      );
}

class DietRequestNotifier extends Notifier<DietRequestState> {
  @override
  DietRequestState build() => const DietRequestState();

  Future<bool> submit(Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(dietRequestsRepositoryProvider).createDietRequest(payload);
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(dieticianRequestsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final dietRequestProvider =
    NotifierProvider<DietRequestNotifier, DietRequestState>(DietRequestNotifier.new);

// ── Update Diet Request state ──────────────────────────────────────────────

class UpdateDietRequestState {
  final bool loading;
  final String? error;
  final bool success;
  const UpdateDietRequestState({this.loading = false, this.error, this.success = false});
  UpdateDietRequestState copyWith({bool? loading, String? error, bool? success}) =>
      UpdateDietRequestState(
        loading: loading ?? this.loading,
        error:   error,
        success: success ?? this.success,
      );
}

class UpdateDietRequestNotifier extends Notifier<UpdateDietRequestState> {
  @override
  UpdateDietRequestState build() => const UpdateDietRequestState();

  Future<bool> update(String id, Map<String, dynamic> data) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(dietRequestsRepositoryProvider).updateDietRequest(id, data);
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(dieticianRequestsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final updateDietRequestProvider =
    NotifierProvider<UpdateDietRequestNotifier, UpdateDietRequestState>(
        UpdateDietRequestNotifier.new);
