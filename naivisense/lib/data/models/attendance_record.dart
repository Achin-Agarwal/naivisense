class AttendanceRecord {
  final String id;
  final String childId;
  final String? sessionId;
  final DateTime date;
  final String status; // present | absent | late
  final String markedBy;
  final String? notes;

  const AttendanceRecord({
    required this.id,
    required this.childId,
    this.sessionId,
    required this.date,
    required this.status,
    required this.markedBy,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id:        j['_id'] as String? ?? '',
        childId:   j['child_id'] as String? ?? '',
        sessionId: j['session_id'] as String?,
        date:      DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        status:    j['status'] as String? ?? 'present',
        markedBy:  j['marked_by'] as String? ?? '',
        notes:     j['notes'] as String?,
      );

  String get statusLabel => switch (status) {
    'present' => 'Present',
    'absent'  => 'Absent',
    'late'    => 'Late',
    _         => status,
  };
}
