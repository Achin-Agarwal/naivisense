import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../data/models/therapist_overview.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/alerts_repository.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/diet_plans_repository.dart';
import '../../../data/repositories/home_plans_repository.dart';
import '../../../data/repositories/sessions_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/error_handler_service.dart';

final centerChildrenProvider = FutureProvider<List<ChildModel>>((ref) async {
  final repo = ref.read(childrenRepositoryProvider);
  final result = await repo.getChildren();
  return result;
});

final therapistsOverviewProvider = FutureProvider<List<TherapistOverview>>((
  ref,
) async {
  try {
    final api = ref.read(apiServiceProvider);
    final res = await api.get<List<dynamic>>('/users/therapists-overview');
    final list = res.data ?? [];
    return list
        .map((e) => TherapistOverview.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});

final adminChildSessionsProvider =
    FutureProvider.family<List<SessionModel>, String>(
      (ref, childId) =>
          ref.read(sessionsRepositoryProvider).getSessions(childId: childId),
    );

final adminChildPlanProvider = FutureProvider.family<HomePlanModel?, String>(
  (ref, childId) =>
      ref.read(homePlansRepositoryProvider).getActivePlan(childId),
);

final adminChildDietPlanProvider =
    FutureProvider.family<DietPlanModel?, String>(
      (ref, childId) =>
          ref.read(dietPlansRepositoryProvider).getActivePlan(childId),
    );

final adminChildAlertsProvider =
    FutureProvider.family<List<AlertModel>, String>(
      (ref, childId) => ref.read(alertsRepositoryProvider).getAlerts(childId),
    );

final allParentsProvider = FutureProvider<List<UserModel>>((ref) async {
  try {
    final api = ref.read(apiServiceProvider);
    final res = await api.get<List<dynamic>>(
      '/users/staff',
      params: {'role': 'parent'},
    );
    final list = res.data ?? [];
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});

final adminUserProvider = FutureProvider.family<UserModel, String>((
  ref,
  userId,
) async {
  try {
    final api = ref.read(apiServiceProvider);
    final res = await api.get('/users/$userId');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});
