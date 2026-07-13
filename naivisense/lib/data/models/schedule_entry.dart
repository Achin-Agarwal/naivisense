class ScheduleEntry {
  final String enrollmentMode; // online/offline
  final List<int> days;
  final String fromTime;
  final String toTime;

  const ScheduleEntry({
    required this.enrollmentMode,
    required this.days,
    required this.fromTime,
    required this.toTime,
  });

  ScheduleEntry copyWith({
    String? enrollmentMode,
    List<int>? days,
    String? fromTime,
    String? toTime,
  }) {
    return ScheduleEntry(
      enrollmentMode: enrollmentMode ?? this.enrollmentMode,
      days: days ?? this.days,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
    );
  }
}
