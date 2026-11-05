class ReviewModel {
  final String id;
  final String customerName;
  final String customerAvatar;
  final double rating;
  final String date;
  final String serviceName;
  final String comment;
  String? providerReply;
  final String? serviceId;
  final String? customerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.customerAvatar,
    required this.rating,
    required this.date,
    required this.serviceName,
    required this.comment,
    this.providerReply,
    this.serviceId,
    this.customerId,
    this.createdAt,
    this.updatedAt,
  });

  ReviewModel copyWith({
    String? id,
    String? customerName,
    String? customerAvatar,
    double? rating,
    String? date,
    String? serviceName,
    String? comment,
    String? providerReply,
    String? serviceId,
    String? customerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      serviceName: serviceName ?? this.serviceName,
      comment: comment ?? this.comment,
      providerReply: providerReply ?? this.providerReply,
      serviceId: serviceId ?? this.serviceId,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final profile =
        (json['customer'] ?? json['profiles']) as Map<String, dynamic>?;
    final service =
        (json['service'] ?? json['services']) as Map<String, dynamic>?;
    final ratingNum = json['rating'];

    DateTime? parsedCreatedAt;
    String formattedDate = '';
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        parsedCreatedAt = DateTime.parse(createdAtStr);
        final now = DateTime.now();
        final diff = now.difference(parsedCreatedAt);

        if (diff.inDays == 0) {
          if (diff.inHours == 0) {
            formattedDate = diff.inMinutes <= 1 ? 'الآن' : 'منذ ${diff.inMinutes} دقيقة';
          } else {
            formattedDate = 'منذ ${diff.inHours} ساعة';
          }
        } else if (diff.inDays == 1) {
          formattedDate = 'أمس';
        } else if (diff.inDays < 7) {
          formattedDate = 'منذ ${diff.inDays} أيام';
        } else if (diff.inDays < 30) {
          formattedDate = 'منذ ${(diff.inDays / 7).floor()} أسابيع';
        } else {
          formattedDate = '${parsedCreatedAt.year}/${parsedCreatedAt.month.toString().padLeft(2, '0')}/${parsedCreatedAt.day.toString().padLeft(2, '0')}';
        }
      } catch (_) {
        formattedDate = createdAtStr;
      }
    }

    DateTime? parsedUpdatedAt;
    final updatedAtStr = json['updated_at'] as String?;
    if (updatedAtStr != null) {
      try {
        parsedUpdatedAt = DateTime.parse(updatedAtStr);
      } catch (_) {}
    }

    final rawName = profile?['full_name'] as String? ??
        json['customer_name'] as String? ??
        '';

    return ReviewModel(
      id: json['id'] as String? ?? '',
      customerName: rawName.trim().isNotEmpty ? rawName.trim() : 'عميل خِدمتي',
      customerAvatar: profile?['avatar_url'] as String? ??
          json['customer_avatar'] as String? ??
          '',
      rating: ratingNum != null ? (ratingNum as num).toDouble() : 5.0,
      date: formattedDate.isNotEmpty ? formattedDate : 'مؤخراً',
      serviceName: service?['name'] as String? ??
          json['service_name'] as String? ??
          'خدمة مميزة',
      comment: (json['comment'] as String? ?? '').trim(),
      providerReply: json['provider_reply'] as String?,
      serviceId: json['service_id'] as String? ?? service?['id'] as String?,
      customerId: json['customer_id'] as String? ?? profile?['id'] as String?,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating.toInt(),
      'comment': comment,
      'provider_reply': providerReply,
      'service_id': serviceId,
      'customer_id': customerId,
    };
  }
}
