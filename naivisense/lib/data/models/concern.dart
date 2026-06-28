class ConcernModel {
  final String id;
  final String childId;
  final String createdBy;
  final String createdByRole; // parent|therapist|clinical_psychologist
  final String category;      // tantrum|behavior|health|regression|activity|other
  final String description;
  final String status;        // open | resolved
  final String? resolution;
  final DateTime createdAt;

  const ConcernModel({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.createdByRole,
    required this.category,
    required this.description,
    required this.status,
    this.resolution,
    required this.createdAt,
  });

  bool get isOpen => status == 'open';

  factory ConcernModel.fromJson(Map<String, dynamic> j) => ConcernModel(
        id:            j['_id'] as String? ?? '',
        childId:       j['child_id'] as String? ?? '',
        createdBy:     j['created_by'] as String? ?? '',
        createdByRole: j['created_by_role'] as String? ?? 'parent',
        category:      j['category'] as String? ?? 'other',
        description:   j['description'] as String? ?? '',
        status:        j['status'] as String? ?? 'open',
        resolution:    j['resolution'] as String?,
        createdAt:     DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get categoryLabel => switch (category) {
    'tantrum'    => 'Tantrum',
    'behavior'   => 'Behavior',
    'health'     => 'Health',
    'regression' => 'Regression',
    'activity'   => 'Activity',
    _            => 'Other',
  };
}
