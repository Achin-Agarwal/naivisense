# NaiviSense — Doc 2: Flutter Frontend Implementation
> Complete Flutter codebase guide with sample code for every layer.
> Read Doc 1 (Architecture) first. This doc covers the Flutter app only.

---

## 1. Project Setup

### 1.1 pubspec.yaml

```yaml
name: naivisense
description: AI-Powered Therapy Platform — Smarter Care for Every Child
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # ── State & Navigation ────────────────────────────────────────
  flutter_riverpod:     ^2.5.1
  riverpod_annotation:  ^2.3.5
  go_router:            ^13.2.4

  # ── HTTP & Storage ────────────────────────────────────────────
  dio:                        ^5.4.3
  flutter_secure_storage:     ^9.0.0
  hive_flutter:               ^1.1.0      # offline cache

  # ── UI & Charts ───────────────────────────────────────────────
  fl_chart:               ^0.68.0
  cached_network_image:   ^3.3.1
  image_picker:           ^1.1.2
  lottie:                 ^3.1.2

  # ── Utilities ─────────────────────────────────────────────────
  intl:                ^0.19.0
  connectivity_plus:   ^6.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner:       ^2.4.9
  flutter_lints:      ^3.0.0

flutter:
  uses-material-design: true
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
  assets:
    - assets/fonts/
    - assets/lottie/
    - assets/images/
```

### 1.2 Complete File Structure

```
lib/
├── main.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
│
├── routing/
│   └── app_router.dart
│
├── data/
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── storage_service.dart
│   │   └── error_handler_service.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── child_repository.dart
│   │   ├── session_repository.dart
│   │   ├── feedback_repository.dart
│   │   ├── home_plan_repository.dart
│   │   └── verification_repository.dart
│   └── mock/
│       └── mock_repository.dart
│
├── shared/
│   ├── models/
│   │   ├── user.dart
│   │   ├── child.dart
│   │   ├── session.dart
│   │   ├── home_plan.dart
│   │   └── api/
│   │       ├── auth_requests.dart
│   │       └── auth_responses.dart
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── stat_tile.dart
│   │   ├── emoji_rating.dart
│   │   ├── rating_slider.dart
│   │   └── state_widgets/
│   │       ├── loading_widget.dart
│   │       ├── app_error_widget.dart
│   │       └── empty_state_widget.dart
│   └── charts/
│       └── trend_chart.dart
│
└── features/
    ├── auth/
    │   ├── providers/auth_provider.dart
    │   └── screens/
    │       ├── splash_screen.dart
    │       └── role_login_screen.dart
    ├── center_head/
    │   ├── providers/
    │   │   ├── child_management_provider.dart
    │   │   └── verification_provider.dart
    │   └── screens/
    │       ├── center_head_home.dart
    │       ├── add_child_screen.dart
    │       └── verification_panel_screen.dart
    ├── therapist/
    │   ├── providers/
    │   │   ├── therapist_dashboard_provider.dart
    │   │   ├── session_provider.dart
    │   │   └── child_detail_provider.dart
    │   └── screens/
    │       ├── therapist_home.dart
    │       ├── therapist_children_list.dart
    │       ├── child_profile_screen.dart
    │       ├── session_notes_screen.dart
    │       ├── ai_plan_editor_screen.dart
    │       └── progress_report_screen.dart
    ├── parent/
    │   ├── providers/
    │   │   ├── parent_dashboard_provider.dart
    │   │   └── feedback_provider.dart
    │   └── screens/
    │       ├── parent_home.dart
    │       ├── parent_today_timeline.dart
    │       ├── parent_camera_screen.dart
    │       ├── parent_feedback_screen.dart
    │       └── parent_alerts_screen.dart
    └── reports/
        └── screens/
            └── report_screens.dart
```

---

## 2. Core Layer

### 2.1 main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('pending_proofs');   // offline proof queue
  runApp(const ProviderScope(child: NaiviSenseApp()));
}

class NaiviSenseApp extends ConsumerWidget {
  const NaiviSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title:                  'NaiviSense',
      theme:                  AppTheme.light,
      routerConfig:           router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### 2.2 app_constants.dart

```dart
class AppConstants {
  AppConstants._();

  // API — swap to prod URL before release
  static const String baseUrl      = 'http://10.0.2.2:8000/api/v1'; // Android emulator
  // static const String baseUrl   = 'https://api.naivisense.in/api/v1'; // production

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Secure storage keys
  static const String keyAccessToken  = 'ns_access_token';
  static const String keyRefreshToken = 'ns_refresh_token';
  static const String keyUserRole     = 'ns_user_role';
  static const String keyUserId       = 'ns_user_id';

  // Hive boxes
  static const String boxPendingProofs = 'pending_proofs';

  // Rating scale
  static const int ratingMin  = 1;
  static const int ratingMax  = 10;
  static const int pageSize   = 20;
}
```

### 2.3 app_colors.dart

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue   = Color(0xFF4A90E2);  // buttons, links, CTAs
  static const Color mintGreen     = Color(0xFF4CD7A2);  // success, positive trends
  static const Color warmYellow    = Color(0xFFFFD56B);  // pending, warning
  static const Color softCoral     = Color(0xFFFF7B7B);  // errors — NEVER harsh red

  static const Color background    = Color(0xFFF8FAFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider       = Color(0xFFE5E7EB);

  // Semantic aliases
  static const Color success = mintGreen;
  static const Color warning = warmYellow;
  static const Color error   = softCoral;

  // Role header gradients
  static const LinearGradient therapistGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF2C6FBF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient parentGradient = LinearGradient(
    colors: [Color(0xFF4CD7A2), Color(0xFF2AAD7E)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient centerHeadGradient = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFF6C3483)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
```

### 2.4 app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor:  AppColors.primaryBlue,
      background: AppColors.background,
      surface:    AppColors.surface,
    ),
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      headlineLarge:  TextStyle(fontSize: 28, fontWeight: FontWeight.bold,    color: AppColors.textPrimary, fontFamily: 'Inter'),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,    color: AppColors.textPrimary, fontFamily: 'Inter'),
      headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w600,    color: AppColors.textPrimary, fontFamily: 'Inter'),
      bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.normal,  color: AppColors.textPrimary, fontFamily: 'Inter'),
      bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.normal,  color: AppColors.textSecondary, fontFamily: 'Inter'),
      bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.normal,  color: AppColors.textSecondary, fontFamily: 'Inter'),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.softCoral),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryBlue.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primaryBlue.withOpacity(0.15),
      side: const BorderSide(color: AppColors.divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
```

---

## 3. Routing

### 3.1 app_router.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/role_login_screen.dart';
import '../features/therapist/screens/therapist_home.dart';
import '../features/therapist/screens/session_notes_screen.dart';
import '../features/therapist/screens/child_profile_screen.dart';
import '../features/therapist/screens/ai_plan_editor_screen.dart';
import '../features/parent/screens/parent_home.dart';
import '../features/parent/screens/parent_feedback_screen.dart';
import '../features/parent/screens/parent_camera_screen.dart';
import '../features/center_head/screens/center_head_home.dart';
import '../features/center_head/screens/add_child_screen.dart';
import '../features/center_head/screens/verification_panel_screen.dart';
import '../shared/models/user.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final atLogin = ['/login', '/splash'].contains(state.matchedLocation);
      final authed  = authState.status == AuthStatus.authenticated;
      final unauthd = authState.status == AuthStatus.unauthenticated;

      if (unauthd && !atLogin) return '/login';
      if (authed  &&  atLogin) return _homeForRole(authState.user!.role);
      return null;
    },
    routes: [
      GoRoute(path: '/splash',      builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',       builder: (_, __) => const RoleLoginScreen()),

      // ── Therapist ─────────────────────────────────────────────
      GoRoute(path: '/therapist',   builder: (_, __) => const TherapistHome()),
      GoRoute(
        path: '/child/:id',
        builder: (_, s) => ChildProfileScreen(childId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/session/:sessionId/notes',
        builder: (_, s) => SessionNotesScreen(sessionId: s.pathParameters['sessionId']!),
      ),
      GoRoute(
        path: '/child/:id/ai-plan',
        builder: (_, s) => AIPlanEditorScreen(childId: s.pathParameters['id']!),
      ),

      // ── Parent ────────────────────────────────────────────────
      GoRoute(path: '/parent',        builder: (_, __) => const ParentHome()),
      GoRoute(path: '/parent/feedback', builder: (_, __) => const ParentFeedbackScreen()),
      GoRoute(
        path: '/parent/camera/:taskId',
        builder: (_, s) => ParentCameraScreen(taskId: s.pathParameters['taskId']!),
      ),

      // ── Center Head ───────────────────────────────────────────
      GoRoute(path: '/center-head', builder: (_, __) => const CenterHeadHome()),
      GoRoute(path: '/add-child',   builder: (_, __) => const AddChildScreen()),
      GoRoute(
        path: '/verify/:logId',
        builder: (_, s) => VerificationPanelScreen(logId: s.pathParameters['logId']!),
      ),
    ],
  );
});

String _homeForRole(UserRole role) => switch (role) {
  UserRole.therapist  => '/therapist',
  UserRole.parent     => '/parent',
  UserRole.centerHead => '/center-head',
};
```

---

## 4. Data Layer — Services

### 4.1 storage_service.dart

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

final storageServiceProvider = Provider<StorageService>((_) => StorageService());

class StorageService {
  final _s = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveTokens({required String access, required String refresh}) async {
    await Future.wait([
      _s.write(key: AppConstants.keyAccessToken,  value: access),
      _s.write(key: AppConstants.keyRefreshToken, value: refresh),
    ]);
  }

  Future<String?> getAccessToken()  => _s.read(key: AppConstants.keyAccessToken);
  Future<String?> getRefreshToken() => _s.read(key: AppConstants.keyRefreshToken);

  Future<void>    saveRole(String role) => _s.write(key: AppConstants.keyUserRole, value: role);
  Future<String?> getRole()            => _s.read(key: AppConstants.keyUserRole);

  Future<void> clear() => _s.deleteAll();
}
```

### 4.2 api_service.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(storageServiceProvider));
});

class UserFriendlyError {
  final String message;
  final String code;
  final bool retryable;
  const UserFriendlyError(this.message, this.code, {this.retryable = false});

  @override String toString() => message;
}

class ApiService {
  late final Dio dio;
  final StorageService _storage;

  ApiService(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl:        AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers:        {'Content-Type': 'application/json'},
    ));

    // 1. Token injector
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) opts.headers['Authorization'] = 'Bearer $token';
        handler.next(opts);
      },
    ));

    // 2. 401 refresh + retry (once)
    dio.interceptors.add(InterceptorsWrapper(
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          try {
            await _refreshTokens();
            final retried = await _retry(err.requestOptions);
            return handler.resolve(retried);
          } catch (_) {
            await _storage.clear();
          }
        }
        handler.next(err);
      },
    ));

    // 3. Error mapper — backend codes → UserFriendlyError
    dio.interceptors.add(InterceptorsWrapper(
      onError: (err, handler) {
        final data    = err.response?.data as Map?;
        final errObj  = data?['error'] as Map?;
        final code    = errObj?['code'] as String? ?? 'SERVER_ERROR';
        final message = errObj?['message'] as String? ?? 'Something went wrong. Please try again.';
        final retry   = errObj?['retryable'] as bool? ?? false;
        err.error = UserFriendlyError(message, code, retryable: retry);
        handler.next(err);
      },
    ));

    // 4. Debug logging
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    }
  }

  Future<void> _refreshTokens() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) throw Exception('No refresh token');
    final res = await Dio().post(
      '${AppConstants.baseUrl}/auth/refresh',
      data: {'refreshToken': refresh},
    );
    await _storage.saveTokens(
      access:  res.data['accessToken']  as String,
      refresh: res.data['refreshToken'] as String,
    );
  }

  Future<Response<dynamic>> _retry(RequestOptions req) async {
    final token = await _storage.getAccessToken();
    return dio.request(
      req.path,
      options: Options(
        method: req.method,
        headers: {'Authorization': 'Bearer $token'},
      ),
      data:            req.data,
      queryParameters: req.queryParameters,
    );
  }
}
```

---

## 5. Data Layer — Models

### 5.1 user.dart

```dart
enum UserRole {
  therapist, parent, centerHead;

  static UserRole fromString(String s) => switch (s) {
    'therapist'   => therapist,
    'parent'      => parent,
    'center_head' => centerHead,
    _             => throw ArgumentError('Unknown role: $s'),
  };

  String get apiValue => switch (this) {
    therapist  => 'therapist',
    parent     => 'parent',
    centerHead => 'center_head',
  };

  String get displayName => switch (this) {
    therapist  => 'Therapist',
    parent     => 'Parent',
    centerHead => 'Center Head',
  };
}

class AppUser {
  final String   id;
  final String   name;
  final String   phone;
  final String?  email;
  final UserRole role;
  final String?  photoUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id:       j['_id']       as String,
    name:     j['name']      as String,
    phone:    j['phone']     as String,
    email:    j['email']     as String?,
    role:     UserRole.fromString(j['role'] as String),
    photoUrl: j['photo_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    '_id': id, 'name': name, 'phone': phone,
    'email': email, 'role': role.apiValue, 'photo_url': photoUrl,
  };
}
```

### 5.2 child.dart

```dart
class Child {
  final String       id;
  final String       name;
  final String?      nickname;
  final DateTime     dob;
  final String       gender;
  final List<String> diagnosis;
  final String       severity;
  final List<String> therapyTargets;
  final String?      therapistId;
  final String       parentId;
  final HomeContext  homeContext;
  final String?      photoUrl;

  const Child({
    required this.id,       required this.name,
    this.nickname,          required this.dob,
    required this.gender,   required this.diagnosis,
    required this.severity, required this.therapyTargets,
    this.therapistId,       required this.parentId,
    required this.homeContext, this.photoUrl,
  });

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  factory Child.fromJson(Map<String, dynamic> j) => Child(
    id:             j['_id']              as String,
    name:           j['name']             as String,
    nickname:       j['nickname']         as String?,
    dob:            DateTime.parse(j['dob'] as String),
    gender:         j['gender']           as String,
    diagnosis:      List<String>.from(j['diagnosis'] as List),
    severity:       j['severity']         as String,
    therapyTargets: List<String>.from(j['therapy_targets'] as List),
    therapistId:    j['therapist_id']     as String?,
    parentId:       j['parent_id']        as String,
    homeContext:    HomeContext.fromJson(j['home_context'] ?? {}),
    photoUrl:       j['photo_url']        as String?,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,  'name': name,         'nickname': nickname,
    'dob': dob.toIso8601String(),     'gender': gender,
    'diagnosis': diagnosis,            'severity': severity,
    'therapy_targets': therapyTargets, 'therapist_id': therapistId,
    'parent_id': parentId,             'home_context': homeContext.toJson(),
    'photo_url': photoUrl,
  };
}

class HomeContext {
  final int    screenTimeHours;
  final String playType;           // alone | guided | group
  final String parentInvolvement;  // low | medium | high

  const HomeContext({
    this.screenTimeHours  = 0,
    this.playType         = 'guided',
    this.parentInvolvement = 'medium',
  });

  factory HomeContext.fromJson(Map<String, dynamic> j) => HomeContext(
    screenTimeHours:   (j['screen_time_hours']  as int?)    ?? 0,
    playType:          (j['play_type']           as String?) ?? 'guided',
    parentInvolvement: (j['parent_involvement']  as String?) ?? 'medium',
  );

  Map<String, dynamic> toJson() => {
    'screen_time_hours':  screenTimeHours,
    'play_type':          playType,
    'parent_involvement': parentInvolvement,
  };
}
```

### 5.3 session.dart

```dart
class Session {
  final String        id;
  final String        childId;
  final String        therapistId;
  final DateTime      scheduledAt;
  final String        status;    // scheduled | completed | cancelled
  final String        type;      // speech | ot | behavior | special_ed
  final SessionNotes? notes;

  const Session({
    required this.id,          required this.childId,
    required this.therapistId, required this.scheduledAt,
    required this.status,      required this.type,
    this.notes,
  });

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    id:           j['_id']          as String,
    childId:      j['child_id']     as String,
    therapistId:  j['therapist_id'] as String,
    scheduledAt:  DateTime.parse(j['scheduled_at'] as String),
    status:       j['status']       as String,
    type:         j['type']         as String,
    notes: j['notes'] != null
        ? SessionNotes.fromJson(j['notes'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    '_id': id, 'child_id': childId, 'therapist_id': therapistId,
    'scheduled_at': scheduledAt.toIso8601String(),
    'status': status, 'type': type, 'notes': notes?.toJson(),
  };
}

class SessionNotes {
  final String       mood;
  final int          attentionScore;
  final int          communicationScore;
  final int          motorScore;
  final int          behaviorScore;
  final List<String> activities;
  final String?      notes;

  const SessionNotes({
    required this.mood,
    required this.attentionScore,
    required this.communicationScore,
    required this.motorScore,
    required this.behaviorScore,
    required this.activities,
    this.notes,
  });

  factory SessionNotes.fromJson(Map<String, dynamic> j) => SessionNotes(
    mood:               j['mood']               as String,
    attentionScore:     j['attention_score']     as int,
    communicationScore: j['communication_score'] as int,
    motorScore:         j['motor_score']         as int,
    behaviorScore:      j['behavior_score']      as int,
    activities:         List<String>.from(j['activities'] as List),
    notes:              j['notes']               as String?,
  );

  Map<String, dynamic> toJson() => {
    'mood':               mood,
    'attention_score':    attentionScore,
    'communication_score': communicationScore,
    'motor_score':        motorScore,
    'behavior_score':     behaviorScore,
    'activities':         activities,
    'notes':              notes,
  };
}
```

### 5.4 home_plan.dart

```dart
class HomePlan {
  final String     id;
  final String     childId;
  final DateTime   startDate;
  final DateTime   endDate;
  final List<Task> tasks;

  const HomePlan({
    required this.id,        required this.childId,
    required this.startDate, required this.endDate,
    required this.tasks,
  });

  factory HomePlan.fromJson(Map<String, dynamic> j) => HomePlan(
    id:        j['_id']                       as String,
    childId:   j['child_id']                  as String,
    startDate: DateTime.parse(j['start_date'] as String),
    endDate:   DateTime.parse(j['end_date']   as String),
    tasks:     (j['tasks'] as List).map((t) => Task.fromJson(t)).toList(),
  );

  Map<String, dynamic> toJson() => {
    '_id': id, 'child_id': childId,
    'start_date': startDate.toIso8601String(),
    'end_date':   endDate.toIso8601String(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };
}

class Task {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String timeOfDay;   // morning | afternoon | evening
  final int    durationMin;
  final String frequency;   // daily | weekly
  bool         isCompleted;

  Task({
    required this.id,         required this.title,
    required this.description, required this.icon,
    required this.timeOfDay,  required this.durationMin,
    required this.frequency,  this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id:          j['task_id']     as String,
    title:       j['title']       as String,
    description: j['description'] as String,
    icon:        j['icon']        as String? ?? '✅',
    timeOfDay:   j['time_of_day'] as String,
    durationMin: j['duration_min'] as int,
    frequency:   j['frequency']   as String,
  );

  Map<String, dynamic> toJson() => {
    'task_id': id, 'title': title, 'description': description,
    'icon': icon, 'time_of_day': timeOfDay,
    'duration_min': durationMin, 'frequency': frequency,
  };
}
```

---

## 6. Data Layer — Repositories

### 6.1 auth_repository.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../shared/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider), ref.read(storageServiceProvider));
});

class AuthRepository {
  final ApiService     _api;
  final StorageService _storage;
  AuthRepository(this._api, this._storage);

  Future<AppUser> login({required String phone, required String password}) async {
    final res = await _api.dio.post('/auth/login', data: {'phone': phone, 'password': password});
    await _storage.saveTokens(
      access:  res.data['accessToken']  as String,
      refresh: res.data['refreshToken'] as String,
    );
    final user = AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    await _storage.saveRole(user.role.apiValue);
    return user;
  }

  Future<AppUser> register({
    required String   name,
    required String   phone,
    required String   password,
    required UserRole role,
  }) async {
    final res = await _api.dio.post('/auth/register', data: {
      'name': name, 'phone': phone, 'password': password, 'role': role.apiValue,
    });
    await _storage.saveTokens(
      access:  res.data['accessToken']  as String,
      refresh: res.data['refreshToken'] as String,
    );
    return AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try { await _api.dio.post('/auth/logout'); } finally { await _storage.clear(); }
  }

  Future<AppUser?> tryAutoLogin() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    final res = await _api.dio.get('/users/me');
    return AppUser.fromJson(res.data as Map<String, dynamic>);
  }
}
```

### 6.2 child_repository.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../shared/models/child.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return ChildRepository(ref.read(apiServiceProvider));
});

class ChildRepository {
  final ApiService _api;
  ChildRepository(this._api);

  Future<List<Child>> list() async {
    final res = await _api.dio.get('/children');
    return (res.data as List).map((j) => Child.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Child> get(String id) async {
    final res = await _api.dio.get('/children/$id');
    return Child.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Child> create(Map<String, dynamic> payload) async {
    final res = await _api.dio.post('/children', data: payload);
    return Child.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Child> update(String id, Map<String, dynamic> payload) async {
    final res = await _api.dio.patch('/children/$id', data: payload);
    return Child.fromJson(res.data as Map<String, dynamic>);
  }
}
```

### 6.3 session_repository.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../shared/models/session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.read(apiServiceProvider));
});

class SessionRepository {
  final ApiService _api;
  SessionRepository(this._api);

  Future<List<Session>> getUpcoming() async {
    final res = await _api.dio.get('/sessions/upcoming');
    print("Upcoming sessions:");
  print(res.data);
    return (res.data as List).map((j) => Session.fromJson(j)).toList();
  }

  Future<List<Session>> getForChild(String childId) async {
    final res = await _api.dio.get('/sessions', queryParameters: {'childId': childId});
    return (res.data as List).map((j) => Session.fromJson(j)).toList();
  }

  Future<Session> create({
    required String   childId,
    required DateTime scheduledAt,
    required String   type,
  }) async {
    final res = await _api.dio.post('/sessions', data: {
      'child_id':     childId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'type':         type,
    });
    return Session.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> submitNotes(String sessionId, SessionNotes notes) async {
    await _api.dio.post('/sessions/$sessionId/notes', data: notes.toJson());
  }
}
```

### 6.4 home_plan_repository.dart

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../shared/models/home_plan.dart';

final homePlanRepositoryProvider = Provider<HomePlanRepository>((ref) {
  return HomePlanRepository(ref.read(apiServiceProvider));
});

class HomePlanRepository {
  final ApiService _api;
  HomePlanRepository(this._api);

  Future<HomePlan?> getActive(String childId) async {
    final res = await _api.dio.get('/home-plans/active', queryParameters: {'childId': childId});
    if (res.data == null) return null;
    return HomePlan.fromJson(res.data as Map<String, dynamic>);
  }

  /// Parent submits proof photo for a task
  Future<void> logTaskCompletion({
    required String planId,
    required String taskId,
    required File   photo,
  }) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(photo.path, filename: 'proof.jpg'),
    });
    await _api.dio.post('/home-plans/$planId/tasks/$taskId/log', data: form);
  }
}
```

---

## 7. State Layer — Providers

### 7.1 auth_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/models/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser?   user;
  final String?    error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, AppUser? user, String? error}) =>
    AuthState(status: status ?? this.status, user: user ?? this.user, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _autoLogin();
  }

  Future<void> _autoLogin() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.tryAutoLogin();
      state = user != null
          ? state.copyWith(status: AuthStatus.authenticated, user: user)
          : state.copyWith(status: AuthStatus.unauthenticated);
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String phone, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.login(phone: phone, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error:  e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
```

### 7.2 therapist_dashboard_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../shared/models/child.dart';
import '../../../shared/models/session.dart';

class TherapistDashboard {
  final List<Child>   children;
  final List<Session> upcomingSessions;
  final int           pendingFeedback;

  const TherapistDashboard({
    required this.children,
    required this.upcomingSessions,
    this.pendingFeedback = 0,
  });
}

final therapistDashboardProvider = FutureProvider.autoDispose<TherapistDashboard>((ref) async {
  final children = await ref.read(childRepositoryProvider).list();
  final sessions = await ref.read(sessionRepositoryProvider).getUpcoming();
  return TherapistDashboard(children: children, upcomingSessions: sessions);
});
```

### 7.3 feedback_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api_service.dart';

class DailyFeedback {
  final String mood;
  final int    sleepScore;
  final int    appetiteScore;
  final int    communicationScore;
  final int    meltdownScore;
  final int    socialScore;
  final String? notes;

  const DailyFeedback({
    required this.mood,
    required this.sleepScore,
    required this.appetiteScore,
    required this.communicationScore,
    required this.meltdownScore,
    required this.socialScore,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'type': 'parent_feedback',
    'mood': mood,
    'traits': {
      'sleep':         sleepScore,
      'appetite':      appetiteScore,
      'communication': communicationScore,
      'meltdown':      meltdownScore,
      'social':        socialScore,
    },
    'notes': notes,
  };
}

class FeedbackNotifier extends StateNotifier<AsyncValue<void>> {
  final ApiService _api;
  FeedbackNotifier(this._api) : super(const AsyncValue.data(null));

  Future<void> submit({required String childId, required DailyFeedback feedback}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _api.dio.post('/assessments', data: {
        'child_id': childId,
        ...feedback.toJson(),
      });
    });
  }

  void reset() => state = const AsyncValue.data(null);
}

final feedbackProvider =
    StateNotifierProvider.autoDispose<FeedbackNotifier, AsyncValue<void>>((ref) {
  return FeedbackNotifier(ref.read(apiServiceProvider));
});
```

---

## 8. Screens — Auth

### 8.1 splash_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter's redirect handles navigation once auth state resolves.
    // All we show is the branded loader.
    ref.listen(authProvider, (_, auth) {
      // GoRouter listens too — no manual push needed here.
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Logo(),
            const SizedBox(height: 24),
            Text('NaiviSense',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primaryBlue,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 8),
            Text('Smarter Care for Every Child',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 56),
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue, strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 88, height: 88,
    decoration: BoxDecoration(
      gradient: AppColors.therapistGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.25),
          blurRadius: 24, offset: const Offset(0, 8),
        ),
      ],
    ),
    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 44),
  );
}
```

### 8.2 role_login_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user.dart';

class RoleLoginScreen extends ConsumerStatefulWidget {
  const RoleLoginScreen({super.key});
  @override
  ConsumerState<RoleLoginScreen> createState() => _State();
}

class _State extends ConsumerState<RoleLoginScreen> {
  UserRole _role = UserRole.therapist;
  final _phone   = TextEditingController();
  final _pass    = TextEditingController();
  final _form    = GlobalKey<FormState>();
  bool  _obscure = true;

  @override
  void dispose() { _phone.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
      phone: _phone.text.trim(), password: _pass.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth    = ref.watch(authProvider);
    final loading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('Login to continue', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 32),

                // Role selector chips
                Row(children: UserRole.values.where((r) => r != UserRole.centerHead).map((r) {
                  final sel = _role == r;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _role = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primaryBlue : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: sel ? AppColors.primaryBlue : AppColors.divider,
                              width: 2,
                            ),
                          ),
                          child: Column(children: [
                            Icon(
                              r == UserRole.therapist ? Icons.medical_services_outlined : Icons.family_restroom,
                              color: sel ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(r.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppColors.textPrimary,
                              )),
                          ]),
                        ),
                      ),
                    ),
                  );
                }).toList()),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixText: '+91 ',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => (v?.length ?? 0) < 10 ? 'Enter valid 10-digit number' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) < 6 ? 'Minimum 6 characters' : null,
                ),

                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softCoral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(auth.error!,
                        style: const TextStyle(color: AppColors.softCoral, fontSize: 14)),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: loading ? null : _login,
                  child: loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Your data is safe & secure',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 9. Screens — Therapist

### 9.1 session_notes_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../shared/models/session.dart';

class SessionNotesScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const SessionNotesScreen({super.key, required this.sessionId});
  @override
  ConsumerState<SessionNotesScreen> createState() => _State();
}

class _State extends ConsumerState<SessionNotesScreen> {
  String _mood          = 'happy';
  int    _attention     = 5;
  int    _communication = 5;
  int    _motor         = 5;
  int    _behavior      = 5;
  final  _notesCtrl     = TextEditingController();
  final  _selectedActs  = <String>{};
  bool   _saving        = false;

  static const _moods = [
    ('😟','sad','Sad'), ('😐','calm','Calm'), ('😊','happy','Happy'), ('🤩','excited','Excited'),
  ];
  static const _activities = [
    'Ball Play','Sound Imitation','Fine Motor','Breathing Exercise',
    'Flashcards','Peer Play','Eye Contact','Mirror Imitation','Pencil Grip',
  ];

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(sessionRepositoryProvider).submitNotes(
        widget.sessionId,
        SessionNotes(
          mood: _mood,
          attentionScore: _attention,
          communicationScore: _communication,
          motorScore: _motor,
          behaviorScore: _behavior,
          activities: _selectedActs.toList(),
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        ),
      );
      if (mounted) { context.pop(); }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.softCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Session Notes')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Mood row
        _Label('Mood Today'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _moods.map((m) {
            final sel = _mood == m.$2;
            return GestureDetector(
              onTap: () => setState(() => _mood = m.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:  sel ? AppColors.primaryBlue.withOpacity(0.12) : Colors.transparent,
                  border: Border.all(color: sel ? AppColors.primaryBlue : Colors.transparent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Text(m.$1, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(m.$3, style: TextStyle(fontSize: 11, color: sel ? AppColors.primaryBlue : AppColors.textSecondary)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Sliders
        _Label('Skill Ratings'),
        const SizedBox(height: 12),
        ...[ ('Speech / Communication', _communication, (v) => setState(() => _communication = v)),
             ('Attention & Focus',      _attention,     (v) => setState(() => _attention = v)),
             ('Motor Skills',           _motor,         (v) => setState(() => _motor = v)),
             ('Social Behavior',        _behavior,      (v) => setState(() => _behavior = v)),
        ].map((r) => _RatingSlider(label: r.$1, value: r.$2, onChange: r.$3 as ValueChanged<int>)),

        const SizedBox(height: 24),

        // Activities
        _Label('Activities Done'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _activities.map((a) {
            final sel = _selectedActs.contains(a);
            return FilterChip(
              label: Text(a), selected: sel,
              onSelected: (_) => setState(() {
                sel ? _selectedActs.remove(a) : _selectedActs.add(a);
              }),
              selectedColor: AppColors.primaryBlue.withOpacity(0.15),
              checkmarkColor: AppColors.primaryBlue,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Notes
        _Label('Notes'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesCtrl, maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Observations, improvements, homework assigned...',
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Notes'),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
}

class _RatingSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChange;
  const _RatingSlider({required this.label, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          Text('$value/10',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        ]),
        Slider(
          value: value.toDouble(), min: 1, max: 10, divisions: 9,
          activeColor: AppColors.primaryBlue,
          onChanged: (v) => onChange(v.round()),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('1 · Struggling', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text('10 · Excellent', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ],
    ),
  );
}
```

---

## 10. Screens — Parent

### 10.1 parent_feedback_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feedback_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ParentFeedbackScreen extends ConsumerStatefulWidget {
  const ParentFeedbackScreen({super.key});
  @override
  ConsumerState<ParentFeedbackScreen> createState() => _State();
}

class _State extends ConsumerState<ParentFeedbackScreen> {
  String _mood        = 'happy';
  int    _sleep       = 7;
  int    _appetite    = 6;
  int    _communication = 6;
  int    _meltdown    = 3;
  int    _social      = 5;
  final  _notes       = TextEditingController();

  static const _moods = [
    ('😟','sad'), ('😐','calm'), ('😊','happy'), ('🤩','excited'),
  ];

  Future<void> _submit() async {
    // childId from auth context — in real app, fetch from parent's assigned child
    const childId = 'PLACEHOLDER_CHILD_ID';
    await ref.read(feedbackProvider.notifier).submit(
      childId:  childId,
      feedback: DailyFeedback(
        mood:               _mood,
        sleepScore:         _sleep,
        appetiteScore:      _appetite,
        communicationScore: _communication,
        meltdownScore:      _meltdown,
        socialScore:        _social,
        notes:              _notes.text.isEmpty ? null : _notes.text,
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(feedbackProvider);
    final loading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daily Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
          Text("How was Aarav's day?",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mood selector
          const Text('Mood Today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moods.map((m) {
              final sel = _mood == m.$2;
              return GestureDetector(
                onTap: () => setState(() => _mood = m.$2),
                child: Column(children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(fontSize: sel ? 40 : 30),
                    child: Text(m.$1),
                  ),
                  if (sel)
                    Container(width: 6, height: 6,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue, shape: BoxShape.circle,
                      )),
                ]),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Star ratings
          ...[ ('Sleep Quality',     _sleep,        (v) => setState(() => _sleep        = v)),
               ('Appetite',          _appetite,     (v) => setState(() => _appetite     = v)),
               ('Communication',     _communication,(v) => setState(() => _communication = v)),
               ('Meltdown / Tantrum',_meltdown,     (v) => setState(() => _meltdown     = v)),
               ('Social Interaction',_social,       (v) => setState(() => _social       = v)),
          ].map((r) => _StarCard(label: r.$1, value: r.$2, onChange: r.$3 as ValueChanged<int>)),

          // Notes
          const SizedBox(height: 8),
          TextFormField(
            controller: _notes, maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Anything unusual we should know?',
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: loading ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintGreen),
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Submit Feedback'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StarCard extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChange;
  const _StarCard({required this.label, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) => GestureDetector(
            onTap: () => onChange(i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                i < value ? Icons.star_rounded : Icons.star_border_rounded,
                color: i < value ? AppColors.warmYellow : AppColors.divider,
                size: 32,
              ),
            ),
          )),
        ),
      ]),
    ),
  );
}
```

---

## 11. Shared Widgets

### 11.1 state_widgets/loading_widget.dart

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: AppColors.primaryBlue),
      if (message != null) ...[
        const SizedBox(height: 16),
        Text(message!, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    ]),
  );
}
```

### 11.2 state_widgets/app_error_widget.dart

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  const AppErrorWidget(this.error, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: AppColors.softCoral, size: 48),
        const SizedBox(height: 16),
        Text(error.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary)),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ]),
    ),
  );
}
```

### 11.3 stat_tile.dart

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatTile extends StatelessWidget {
  final String  value;
  final String  label;
  final IconData icon;
  final Color   color;
  const StatTile({super.key, required this.value, required this.label,
                   required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                                   color: AppColors.textPrimary)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ]),
        const SizedBox(height: 8),
        Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ),
  );
}
```

---

## 12. UX Rules (Non-Negotiable)

| Rule | Detail |
|------|--------|
| **Pattern-match AsyncValue** | Every `ref.watch()` must call `.when(data:, loading:, error:)` |
| **No `setState` with Riverpod** | If a provider exists for data, never use local state for it |
| **No `Navigator.push`** | Always `context.go()` or `context.push()` |
| **No hardcoded colors** | Always `AppColors.*` |
| **Touch targets ≥ 44dp** | Apply to every button, chip, and icon button |
| **Coral not red** | `AppColors.softCoral` for errors — never `Colors.red` |
| **Tokens in secure storage only** | `flutter_secure_storage` — never `SharedPreferences` |
| **Photos as multipart** | Never base64 in JSON body |
| **`fl_chart` guard** | Always show `EmptyStateWidget` when data list is empty |
| **`flutter analyze` clean** | Zero warnings before merge |

---

*Last revised: May 2026. Pair with Doc 1 (Architecture) and Doc 3 (Backend).*
