class UserModel {
  final String id;
  final String name;
  final String phone;
  // center_head | therapist | lead_therapist | parent | dietician | clinical_psychologist
  final String role;
  final String? centerId;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.centerId,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id:       (j['_id'] ?? j['id']) as String? ?? '',
        name:     j['name'] as String? ?? '',
        phone:    j['phone'] as String? ?? '',
        role:     j['role'] as String? ?? 'parent',
        centerId: j['center_id'] as String?,
        isActive: j['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        '_id':       id,
        'name':      name,
        'phone':     phone,
        'role':      role,
        'center_id': centerId,
        'is_active': isActive,
      };
}
