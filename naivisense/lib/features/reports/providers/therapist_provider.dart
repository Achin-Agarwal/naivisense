// ── Edit Session ─────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/repositories/sessions_repository.dart';
import 'package:naivisense/features/therapist/providers/therapist_provider.dart';

class EditSessionState {
  final bool loading;
  final String? error;
  final bool success;

  const EditSessionState({
    this.loading = false,
    this.error,
    this.success = false,
  });

  EditSessionState copyWith({bool? loading, String? error, bool? success}) {
    return EditSessionState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class EditSessionNotifier extends Notifier<EditSessionState> {
  @override
  EditSessionState build() => const EditSessionState();

  Future<bool> update(String sessionId, Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);

    try {
      // Temporary until backend API is implemented
      await ref
          .read(sessionsRepositoryProvider)
          .updateSession(sessionId, payload);

      // Refresh therapist home
      ref.invalidate(therapistSessionsProvider);

      state = state.copyWith(loading: false, success: true);

      return true;
    } on UnimplementedError {
      state = state.copyWith(
        loading: false,
        error: 'Editing sessions is not available yet.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final editSessionProvider =
    NotifierProvider<EditSessionNotifier, EditSessionState>(
      EditSessionNotifier.new,
    );
