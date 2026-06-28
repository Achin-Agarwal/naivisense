class PaymentModel {
  final String id;
  final String parentId;
  final String? childId;
  final String? sessionId;
  final String type;
  final int amountPaise;
  final String currency;
  final String status;
  final String? notes;
  final DateTime? paidAt;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.parentId,
    this.childId,
    this.sessionId,
    required this.type,
    required this.amountPaise,
    required this.currency,
    required this.status,
    this.notes,
    this.paidAt,
    required this.createdAt,
  });

  bool get isPaid    => status == 'paid';
  bool get isPending => status == 'pending';
  double get amountRupees => amountPaise / 100.0;

  String get typeLabel => switch (type) {
    'session_fee'    => 'Session Fee',
    'subscription'   => 'Subscription',
    'assessment_fee' => 'Assessment Fee',
    _                => 'Other',
  };

  String get statusLabel => switch (status) {
    'paid'     => 'Paid',
    'failed'   => 'Failed',
    'refunded' => 'Refunded',
    _          => 'Pending',
  };

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
        id:           j['_id'] as String? ?? '',
        parentId:     j['parent_id'] as String? ?? '',
        childId:      j['child_id'] as String?,
        sessionId:    j['session_id'] as String?,
        type:         j['type'] as String? ?? 'other',
        amountPaise:  j['amount_paise'] as int? ?? 0,
        currency:     j['currency'] as String? ?? 'INR',
        status:       j['status'] as String? ?? 'pending',
        notes:        j['notes'] as String?,
        paidAt:       j['paid_at'] != null ? DateTime.tryParse(j['paid_at'] as String) : null,
        createdAt:    DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
