import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/therapist/screens/therapist_home_screen.dart';
import '../../features/parent/screens/parent_home_screen.dart';
import '../../features/parent/screens/child_detail_screen.dart';
import '../../features/parent/screens/raise_alert_screen.dart';
import '../../features/parent/screens/chatbot_screen.dart';
import '../../features/center_head/screens/center_head_home_screen.dart';
import '../../features/center_head/screens/enrollment_wizard_screen.dart';
import '../../features/center_head/screens/therapist_enrollment_wizard_screen.dart';
import '../../features/center_head/screens/admin_child_report_screen.dart';
import '../../features/center_head/screens/parent_enrollment_screen.dart';
import '../../features/lead_therapist/screens/lead_therapist_home_screen.dart';
import '../../features/dietician/screens/dietician_home_screen.dart';
import '../../features/dietician/screens/dietician_child_profile_screen.dart';
import '../../features/clinical_psychologist/screens/clinical_psychologist_home_screen.dart';
import '../../features/center_head/screens/payments_screen.dart';
import '../../features/center_head/screens/settings_screen.dart';
import '../../data/models/child.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final status = authState.valueOrNull?.status;
      final onLogin = state.matchedLocation == '/login';

      if (status == AuthStatus.unknown) return null;
      if (status == AuthStatus.unauthenticated && !onLogin) return '/login';
      if (status == AuthStatus.authenticated && onLogin) {
        final role = authState.valueOrNull?.user?.role ?? '';
        return switch (role) {
          'therapist'              => '/therapist',
          'parent'                 => '/parent',
          'center_head'            => '/center-head',
          'lead_therapist'         => '/lead-therapist',
          'dietician'              => '/dietician',
          'clinical_psychologist'  => '/clinical-psychologist',
          _                        => '/login',
        };
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login',       builder: (ctx, _) => const LoginScreen()),
      GoRoute(path: '/therapist',   builder: (ctx, _) => const TherapistHomeScreen()),
      GoRoute(
        path: '/parent',
        builder: (ctx, _) => const ParentHomeScreen(),
        routes: [
          GoRoute(
            path: 'child/:childId',
            builder: (ctx, state) {
              final child = state.extra as ChildModel;
              return ChildDetailScreen(child: child);
            },
            routes: [
              GoRoute(
                path: 'alert',
                builder: (ctx, state) {
                  final child = state.extra as ChildModel;
                  return RaiseAlertScreen(child: child);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'chatbot',
            builder: (ctx, _) => const ChatbotScreen(),
          ),
        ],
      ),
      GoRoute(path: '/lead-therapist', builder: (ctx, _) => const LeadTherapistHomeScreen()),
      GoRoute(
        path: '/dietician',
        builder: (ctx, _) => const DieticianHomeScreen(),
        routes: [
          GoRoute(
            path: 'child/:childId',
            builder: (ctx, state) =>
                DieticianChildProfileScreen(childId: state.pathParameters['childId']!),
          ),
        ],
      ),
      GoRoute(path: '/clinical-psychologist', builder: (ctx, _) => const ClinicalPsychologistHomeScreen()),
      GoRoute(
        path: '/center-head',
        builder: (ctx, _) => const CenterHeadHomeScreen(),
        routes: [
          GoRoute(path: 'enroll',           builder: (ctx, _) => const EnrollmentWizardScreen()),
          GoRoute(path: 'enroll-therapist', builder: (ctx, _) => const TherapistEnrollmentWizardScreen()),
          GoRoute(path: 'enroll-parent',    builder: (ctx, _) => const ParentEnrollmentScreen()),
          GoRoute(path: 'payments',         builder: (ctx, _) => const PaymentsScreen()),
          GoRoute(path: 'settings',         builder: (ctx, _) => const SettingsScreen()),
          GoRoute(
            path: 'child/:childId',
            builder: (ctx, state) {
              final child = state.extra as ChildModel;
              return AdminChildReportScreen(child: child);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
