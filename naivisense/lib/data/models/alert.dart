class AlertModel {
  final String id;
  final String childId;
  final String raisedBy;
  final String type;        // fever|regression|aggression|seizure|sleep_issue|injury|emotional_stress|other
  final String description;
  final String severity;    // low | medium | high
  final String priority;    // normal | high
  final String category;    // tantrum|behavior|health|regression|activity|video_review|other
  final String source;      // parent|therapist|clinical_psychologist
  final String status;      // open | seen | resolved
  final String? resolutionNote;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.childId,
    required this.raisedBy,
    required this.type,
    required this.description,
    required this.severity,
    required this.priority,
    required this.category,
    required this.source,
    required this.status,
    this.resolutionNote,
    required this.createdAt,
  });

  bool get isHighPriority => priority == 'high';

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
        id:             j['_id'] as String? ?? '',
        childId:        j['child_id'] as String? ?? '',
        raisedBy:       j['raised_by'] as String? ?? '',
        type:           j['type'] as String? ?? 'other',
        description:    j['description'] as String? ?? '',
        severity:       j['severity'] as String? ?? 'low',
        priority:       j['priority'] as String? ?? 'normal',
        category:       j['category'] as String? ?? 'other',
        source:         j['source'] as String? ?? 'parent',
        status:         j['status'] as String? ?? 'open',
        resolutionNote: j['resolution_note'] as String?,
        createdAt:      DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get typeLabel => switch (type) {
    'fever'            => 'Fever',
    'regression'       => 'Regression',
    'aggression'       => 'Aggression',
    'seizure'          => 'Seizure',
    'sleep_issue'      => 'Sleep Issue',
    'injury'           => 'Injury',
    'emotional_stress' => 'Emotional Stress',
    _                  => 'Other',
  };

  String get categoryLabel => switch (category) {
    'tantrum'      => 'Tantrum',
    'behavior'     => 'Behavior',
    'health'       => 'Health',
    'regression'   => 'Regression',
    'activity'     => 'Activity',
    'video_review' => 'Video Review',
    _              => 'Other',
  };
}
