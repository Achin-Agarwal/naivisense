import 'dart:convert';

class SessionNotes {
  final String mood;
  final int attentionScore;
  final int communicationScore;
  final int motorScore;
  final int behaviorScore;
  final List<String> activities;
  final String? whatWorked;
  final String? whatDidntWork;
  final String? homework;
  final String? observations;
  final String? progressLog;
  final String? tantrums;
  final String? resolutionNotes;
  final bool followUpRequired;

  const SessionNotes({
    required this.mood,
    required this.attentionScore,
    required this.communicationScore,
    required this.motorScore,
    required this.behaviorScore,
    required this.activities,
    this.whatWorked,
    this.whatDidntWork,
    this.homework,
    this.observations,
    this.progressLog,
    this.tantrums,
    this.resolutionNotes,
    this.followUpRequired = false,
  });
  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  factory SessionNotes.fromJson(Map<String, dynamic> j) => SessionNotes(
    mood: j['mood'] as String? ?? 'calm',
    attentionScore: j['attention_score'] as int? ?? 5,
    communicationScore: j['communication_score'] as int? ?? 5,
    motorScore: j['motor_score'] as int? ?? 5,
    behaviorScore: j['behavior_score'] as int? ?? 5,
    activities:
        (j['activities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    whatWorked: j['what_worked'] as String?,
    whatDidntWork: j['what_didnt_work'] as String?,
    homework: j['homework'] as String?,
    observations: j['observations'] as String?,
    progressLog: j['progress_log'] as String?,
    tantrums: j['tantrums_observed'] as String?,
    resolutionNotes: j['resolution_notes'] as String?,
    followUpRequired: j['follow_up_required'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'attention_score': attentionScore,
      'communication_score': communicationScore,
      'motor_score': motorScore,
      'behavior_score': behaviorScore,
      'activities': activities,
      'what_worked': whatWorked,
      'what_didnt_work': whatDidntWork,
      'homework': homework,
      'observations': observations,
      'progress_log': progressLog,
      'tantrums_observed': tantrums,
      'resolution_notes': resolutionNotes,
      'follow_up_required': followUpRequired,
    };
  }
}

class SessionModel {
  final String id;
  final String childId;
  final String therapistId;
  final DateTime scheduledAt;
  final int durationMin;
  final String type; // speech | ot | behavior | special_ed
  final String mode; // online | offline
  final String status; // scheduled | completed | cancelled
  final String? meetingLink;
  final SessionNotes? notes;

  const SessionModel({
    required this.id,
    required this.childId,
    required this.therapistId,
    required this.scheduledAt,
    required this.durationMin,
    required this.type,
    required this.mode,
    required this.status,
    this.meetingLink,
    this.notes,
  });

  factory SessionModel.fromJson(Map<String, dynamic> j) {
    final scheduledAtStr = j['scheduled_at'] as String?;
    final notesJson = j['notes'] as Map<String, dynamic>?;

    return SessionModel(
      id: j['_id'] as String? ?? '',
      childId: j['child_id'] as String? ?? '',
      therapistId: j['therapist_id'] as String? ?? '',
      scheduledAt: scheduledAtStr != null
          ? DateTime.parse(scheduledAtStr)
          : DateTime.now(),
      durationMin: j['duration_min'] as int? ?? 45,
      type: j['type'] as String? ?? 'speech',
      mode: j['mode'] as String? ?? 'offline',
      status: j['status'] as String? ?? 'scheduled',
      meetingLink: j['meeting_link'] as String?,
      notes: notesJson != null ? SessionNotes.fromJson(notesJson) : null,
    );
  }

  String get typeLabel => switch (type) {
    'ot' => 'Occupational Therapy',
    'behavior' => 'Behavioral Therapy',
    'special_ed' => 'Special Education',
    _ => 'Speech Therapy',
  };
}
