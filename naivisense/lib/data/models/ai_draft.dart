class AiDraftModel {
  final String id;
  final String childId;
  final String generatedBy;
  final String type; // therapy_plan|home_plan|diet_summary|reinforcement_activities|insights
  final String status; // pending|approved|rejected
  final String content;
  final String modelUsed;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;

  const AiDraftModel({
    required this.id,
    required this.childId,
    required this.generatedBy,
    required this.type,
    required this.status,
    required this.content,
    required this.modelUsed,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
  });

  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'approved';

  String get typeLabel => switch (type) {
    'therapy_plan'              => 'Therapy Plan',
    'home_plan'                 => 'Home Plan',
    'diet_summary'              => 'Diet Summary',
    'reinforcement_activities'  => 'Reinforcement Activities',
    'insights'                  => 'Insights',
    _                           => type,
  };

  factory AiDraftModel.fromJson(Map<String, dynamic> j) => AiDraftModel(
        id:          j['_id'] as String? ?? '',
        childId:     j['child_id'] is Map ? (j['child_id'] as Map)['_id'] as String? ?? '' : j['child_id'] as String? ?? '',
        generatedBy: j['generated_by'] as String? ?? '',
        type:        j['type'] as String? ?? '',
        status:      j['status'] as String? ?? 'pending',
        content:     j['content'] as String? ?? '',
        modelUsed:   j['model_used'] as String? ?? '',
        approvedBy:  j['approved_by'] as String?,
        approvedAt:  j['approved_at'] != null ? DateTime.tryParse(j['approved_at'] as String) : null,
        createdAt:   DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
