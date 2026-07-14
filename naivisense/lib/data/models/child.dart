class SessionSchedule {
  final String enrollmentMode;
  final List<int> days; // 0=Sun, 1=Mon, ..., 6=Sat
  final String fromTime;
  final String toTime;

  const SessionSchedule({
    required this.enrollmentMode,
    required this.days,
    required this.fromTime,
    required this.toTime,
  });

  static const _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  String get daysLabel => days.map((d) => _dayNames[d]).join(', ');

  String get timeLabel => '$fromTime – $toTime';

  factory SessionSchedule.fromJson(Map<String, dynamic> j) {
    return SessionSchedule(
      enrollmentMode: j['enrollment_mode'] as String? ?? 'offline',
      days: (j['days'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [],
      fromTime: j['from_time'] as String? ?? '',
      toTime: j['to_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'enrollment_mode': enrollmentMode,
    'days': days,
    'from_time': fromTime,
    'to_time': toTime,
  };
}

class TherapistAssignmentModel {
  final String therapistId;
  final String therapyType;
  final String? therapistName;
  final String? therapistPhone;
  final SessionSchedule? schedule;

  const TherapistAssignmentModel({
    required this.therapistId,
    required this.therapyType,
    this.therapistName,
    this.therapistPhone,
    this.schedule,
  });

  factory TherapistAssignmentModel.fromJson(Map<String, dynamic> j) {
    final raw = j['therapist_id'];

    final List<dynamic>? scheduleList = j['schedule'] as List<dynamic>?;

    return TherapistAssignmentModel(
      therapistId: raw is Map<String, dynamic>
          ? raw['_id'] as String? ?? ''
          : raw?.toString() ?? '',

      therapyType: j['therapy_type'] as String? ?? '',

      therapistName: raw is Map<String, dynamic>
          ? raw['name'] as String?
          : null,

      therapistPhone: raw is Map<String, dynamic>
          ? raw['phone'] as String?
          : null,

      schedule: scheduleList != null && scheduleList.isNotEmpty
          ? SessionSchedule.fromJson(scheduleList.first as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'therapist_id': therapistId,
    'therapy_type': therapyType,
    if (schedule != null) 'schedule': [schedule!.toJson()],
  };
}

class ChildModel {
  final String id;
  final String name;
  final int ageYears;
  final List<String> diagnosis;
  final String severity;
  final String centerId;
  final List<TherapistAssignmentModel> therapists;
  final String parentId;
  final String? parentName;
  final String? parentPhone;
  final String? avatarUrl;
  final Map<String, dynamic>? homeContext;

  String get therapistId =>
      therapists.isNotEmpty ? therapists.first.therapistId : '';

  String? get therapistName =>
      therapists.isNotEmpty ? therapists.first.therapistName : null;

  String? get therapistPhone =>
      therapists.isNotEmpty ? therapists.first.therapistPhone : null;

  const ChildModel({
    required this.id,
    required this.name,
    required this.ageYears,
    required this.diagnosis,
    required this.severity,
    required this.centerId,
    required this.therapists,
    required this.parentId,
    this.parentName,
    this.parentPhone,
    this.avatarUrl,
    this.homeContext,
  });

  static int _ageFromDob(String? dobStr) {
    if (dobStr == null) return 0;

    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();

      int age = now.year - dob.year;

      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      return age < 0 ? 0 : age;
    } catch (_) {
      return 0;
    }
  }

  static String _extractId(dynamic raw) {
    if (raw == null) return '';

    if (raw is Map<String, dynamic>) {
      return raw['_id'] as String? ?? '';
    }

    return raw.toString();
  }

  static String? _extractName(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['name'] as String?;
    }

    return null;
  }

  static String? _extractPhone(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['phone'] as String?;
    }

    return null;
  }

  factory ChildModel.fromJson(Map<String, dynamic> j) {
    final diag = j['diagnosis'];

    final diagnosis = diag is List
        ? diag.map((e) => e.toString()).toList()
        : (diag != null ? [diag.toString()] : <String>[]);

    final parentRaw = j['parent_id'];

    final therapists =
        (j['therapists'] as List<dynamic>?)
            ?.map(
              (e) =>
                  TherapistAssignmentModel.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return ChildModel(
      id: j['_id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      ageYears: (j['age_years'] as int?) ?? _ageFromDob(j['dob']?.toString()),
      diagnosis: diagnosis,
      severity: j['severity']?.toString() ?? 'mild',
      centerId: _extractId(j['center_id']),
      therapists: therapists,
      parentId: _extractId(parentRaw),
      parentName: _extractName(parentRaw),
      parentPhone: _extractPhone(parentRaw),
      avatarUrl: j['avatar_url'] as String?,
      homeContext: j['home_context'] as Map<String, dynamic>?,
    );
  }
}
