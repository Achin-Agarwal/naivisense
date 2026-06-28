class ReviewModel {
  final String id;
  final String childId;
  final String reviewType;   // monthly | quarterly
  final String createdBy;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String textObservations;
  final String? adminNotes;
  final List<String> videoIds;
  final String? assessmentId;
  final String status;       // draft | published
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.childId,
    required this.reviewType,
    required this.createdBy,
    required this.periodStart,
    required this.periodEnd,
    required this.textObservations,
    this.adminNotes,
    required this.videoIds,
    this.assessmentId,
    required this.status,
    required this.createdAt,
  });

  bool get isPublished => status == 'published';

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
        id:                j['_id'] as String? ?? '',
        childId:           j['child_id'] as String? ?? '',
        reviewType:        j['review_type'] as String? ?? 'monthly',
        createdBy:         j['created_by'] as String? ?? '',
        periodStart:       DateTime.tryParse(j['period_start'] as String? ?? '') ?? DateTime.now(),
        periodEnd:         DateTime.tryParse(j['period_end'] as String? ?? '') ?? DateTime.now(),
        textObservations:  j['text_observations'] as String? ?? '',
        adminNotes:        j['admin_notes'] as String?,
        videoIds:          (j['video_ids'] as List<dynamic>?)
                               ?.map((e) => e.toString()).toList() ?? [],
        assessmentId:      j['assessment_id'] as String?,
        status:            j['status'] as String? ?? 'draft',
        createdAt:         DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get typeLabel => reviewType == 'quarterly' ? 'Quarterly Review' : 'Monthly Review';
}
