class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role; // 'admin', 'provider', 'customer'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'مستخدم خِدمتي',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'customer',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isProvider => role == 'provider';
  bool get isCustomer => role == 'customer';
}
