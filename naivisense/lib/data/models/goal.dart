class GoalModel {
  final String id;
  final String childId;
  final String createdBy;
  final String title;
  final String? description;
  final int priority;
  final String status; // proposed | accepted | active | completed | paused
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? targetDate;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.acceptedBy,
    this.acceptedAt,
    this.targetDate,
    required this.createdAt,
  });

  bool get isAccepted  => status == 'accepted' || status == 'active';
  bool get isCompleted => status == 'completed';

  factory GoalModel.fromJson(Map<String, dynamic> j) => GoalModel(
        id:          j['_id'] as String? ?? '',
        childId:     j['child_id'] as String? ?? '',
        createdBy:   j['created_by'] as String? ?? '',
        title:       j['title'] as String? ?? '',
        description: j['description'] as String?,
        priority:    j['priority'] as int? ?? 0,
        status:      j['status'] as String? ?? 'proposed',
        acceptedBy:  j['accepted_by'] as String?,
        acceptedAt:  j['accepted_at'] != null
            ? DateTime.tryParse(j['accepted_at'] as String)
            : null,
        targetDate:  j['target_date'] != null
            ? DateTime.tryParse(j['target_date'] as String)
            : null,
        createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get statusLabel => switch (status) {
    'proposed'  => 'Proposed',
    'accepted'  => 'Accepted',
    'active'    => 'Active',
    'completed' => 'Completed',
    'paused'    => 'Paused',
    _           => status,
  };
}
