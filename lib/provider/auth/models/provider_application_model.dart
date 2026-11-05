class ProviderApplicationModel {
  final String id;
  final String userId;
  final String businessName;
  final String? description;
  final String? phone;
  final String? address;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined applicant details if available
  final String? applicantFullName;
  final String? applicantEmail;
  final String? category;

  ProviderApplicationModel({
    required this.id,
    required this.userId,
    required this.businessName,
    this.description,
    this.phone,
    this.address,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.applicantFullName,
    this.applicantEmail,
    this.category,
  });

  factory ProviderApplicationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? profileData;
    if (json['profiles'] is Map<String, dynamic>) {
      profileData = json['profiles'] as Map<String, dynamic>;
    }

    final pPhone = json['phone'] as String?;
    final uPhone = profileData?['phone'] as String?;

    return ProviderApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String? ?? 'بدون اسم تجاري',
      description: json['description'] as String?,
      phone: (pPhone != null && pPhone.isNotEmpty) ? pPhone : uPhone,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      applicantFullName: profileData?['full_name'] as String?,
      applicantEmail: profileData?['email'] as String?,
      category: json['category'] as String?,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get displayName => (applicantFullName != null && applicantFullName!.trim().isNotEmpty)
      ? applicantFullName!
      : businessName;

  String get displayPhone => (phone != null && phone!.trim().isNotEmpty)
      ? phone!
      : 'غير متوفر';

  String get displayCity {
    if (address == null || address!.trim().isEmpty) return 'غير محدد';
    final parts = address!.split(RegExp(r'[,،\-]'));
    return parts.first.trim();
  }

  String get displayCategory => (category != null && category!.trim().isNotEmpty)
      ? category!
      : 'خدمات عامة';
}
