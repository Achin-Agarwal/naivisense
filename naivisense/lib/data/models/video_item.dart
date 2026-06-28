class VideoItemModel {
  final String id;
  final String childId;
  final String uploadedBy;
  final String uploadedByRole;
  final String title;
  final String? description;
  final String category;
  final String url;
  final String? thumbnailUrl;
  final String? linkedAlertId;
  final String? linkedConcernId;
  final String? linkedReviewId;
  final String visibility;
  final DateTime createdAt;

  const VideoItemModel({
    required this.id,
    required this.childId,
    required this.uploadedBy,
    required this.uploadedByRole,
    required this.title,
    this.description,
    required this.category,
    required this.url,
    this.thumbnailUrl,
    this.linkedAlertId,
    this.linkedConcernId,
    this.linkedReviewId,
    required this.visibility,
    required this.createdAt,
  });

  bool get isParentVisible => visibility == 'parent_visible';

  String get categoryLabel => switch (category) {
    'concern'              => 'Concern',
    'improvement'          => 'Improvement',
    'session'              => 'Session',
    'review'               => 'Review',
    'clinical_observation' => 'Clinical Observation',
    'education'            => 'Education',
    _                      => category,
  };

  factory VideoItemModel.fromJson(Map<String, dynamic> j) => VideoItemModel(
        id:               j['_id'] as String? ?? '',
        childId:          j['child_id'] as String? ?? '',
        uploadedBy:       j['uploaded_by'] as String? ?? '',
        uploadedByRole:   j['uploaded_by_role'] as String? ?? '',
        title:            j['title'] as String? ?? '',
        description:      j['description'] as String?,
        category:         j['category'] as String? ?? '',
        url:              j['url'] as String? ?? '',
        thumbnailUrl:     j['thumbnail_url'] as String?,
        linkedAlertId:    j['linked_alert_id'] as String?,
        linkedConcernId:  j['linked_concern_id'] as String?,
        linkedReviewId:   j['linked_review_id'] as String?,
        visibility:       j['visibility'] as String? ?? 'internal',
        createdAt:        DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
