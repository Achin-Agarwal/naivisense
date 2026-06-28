class DietRequestModel {
  final String id;
  final String childId;
  final String requestedBy;
  final String requestedByRole;
  final String? assignedDieticianId;
  final String reason;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const DietRequestModel({
    required this.id,
    required this.childId,
    required this.requestedBy,
    required this.requestedByRole,
    this.assignedDieticianId,
    required this.reason,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  bool get isPending    => status == 'requested' || status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted  => status == 'completed';

  String get statusLabel => switch (status) {
    'requested'   => 'Requested',
    'accepted'    => 'Accepted',
    'in_progress' => 'In Progress',
    'completed'   => 'Completed',
    'cancelled'   => 'Cancelled',
    _             => status,
  };

  factory DietRequestModel.fromJson(Map<String, dynamic> j) {
    final childRaw     = j['child_id'];
    final childId      = childRaw is Map ? (childRaw['_id'] as String? ?? '') : (childRaw as String? ?? '');

    return DietRequestModel(
      id:                    j['_id'] as String? ?? '',
      childId:               childId,
      requestedBy:           j['requested_by'] is Map
          ? ((j['requested_by'] as Map)['_id'] as String? ?? '')
          : (j['requested_by'] as String? ?? ''),
      requestedByRole:       j['requested_by_role'] as String? ?? '',
      assignedDieticianId:   j['assigned_dietician_id'] is Map
          ? ((j['assigned_dietician_id'] as Map)['_id'] as String?)
          : j['assigned_dietician_id'] as String?,
      reason:                j['reason'] as String? ?? '',
      status:                j['status'] as String? ?? 'requested',
      notes:                 j['notes'] as String?,
      createdAt:             DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
