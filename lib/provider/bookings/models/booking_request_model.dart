enum BookingRequestStatus {
  pending,
  accepted,
  rejected,
}

class BookingRequestModel {
  final String id;
  final String code; // e.g. #BK-8902 or KH-26-10002
  final String customerName;
  final String customerAvatar;
  final String customerPhone;
  final String location;
  final String timeAgo;
  final int remainingHours;
  final String eventType;
  final String eventDate;
  final String eventTime;
  final int attendeesCount;
  final double budget;
  final String serviceName;
  final String notes;
  BookingRequestStatus status;
  final String? customerId;
  final List<String> bookingItemIds;
  final DateTime? createdAt;

  BookingRequestModel({
    required this.id,
    required this.code,
    required this.customerName,
    required this.customerAvatar,
    required this.customerPhone,
    required this.location,
    required this.timeAgo,
    required this.remainingHours,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.attendeesCount,
    required this.budget,
    required this.serviceName,
    required this.notes,
    this.status = BookingRequestStatus.pending,
    this.customerId,
    this.bookingItemIds = const [],
    this.createdAt,
  });

  factory BookingRequestModel.fromJson(
    Map<String, dynamic> json, {
    String? targetProviderId,
  }) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final customerName = customer?['full_name'] as String? ?? 'عميل خِدمتي';
    final customerPhone = customer?['phone'] as String? ?? 'غير متوفر';
    final customerAvatar = customer?['avatar_url'] as String? ?? '';

    final items = (json['booking_items'] as List?) ?? [];
    final relevantItems = targetProviderId != null
        ? items
            .where((i) => i['services']?['provider_id'] == targetProviderId)
            .toList()
        : items;
    final itemsToUse = (targetProviderId != null && relevantItems.isNotEmpty)
        ? relevantItems
        : (targetProviderId == null ? items : <dynamic>[]);

    String serviceName = itemsToUse
        .map((i) => i['services']?['name']?.toString())
        .where((n) => n != null && n.isNotEmpty)
        .join(' + ');
    if (serviceName.isEmpty) {
      serviceName = json['event_type'] as String? ?? 'خدمة مناسبات';
    }

    String location = json['event_location'] as String? ?? '';
    if (location.isEmpty) {
      final firstService = itemsToUse.isNotEmpty
          ? itemsToUse.first['services'] as Map<String, dynamic>?
          : null;
      final firstServiceLoc = firstService?['location'] as String?;
      location = firstServiceLoc ?? 'صنعاء';
    }

    final double budget = (targetProviderId != null && relevantItems.isNotEmpty)
        ? relevantItems.fold<double>(
            0.0,
            (sum, i) =>
                sum +
                ((i['subtotal'] as num?)?.toDouble() ??
                    ((i['unit_price'] as num?)?.toDouble() ?? 0.0)),
          )
        : ((json['budget'] as num?)?.toDouble() ??
            (json['total_amount'] as num?)?.toDouble() ??
            itemsToUse.fold<double>(
              0.0,
              (sum, i) => sum + ((i['subtotal'] as num?)?.toDouble() ?? 0.0),
            ));

    final rawCode = json['booking_code']?.toString() ??
        'BK-${json['id'].toString().substring(0, 4)}';
    final code = rawCode.startsWith('#') ? rawCode : '#$rawCode';

    final eventDate = json['event_date']?.toString() ?? '';
    final timeSlot = json['time_slot']?.toString() ?? '';
    String eventTime = timeSlot;
    if (timeSlot == 'evening') {
      eventTime = 'مساءً (4:00 م - 11:00 م)';
    } else if (timeSlot == 'morning') {
      eventTime = 'صباحاً (9:00 ص - 2:00 م)';
    } else if (timeSlot.isEmpty) {
      eventTime = 'غير محدد';
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    String timeAgo = 'الآن';
    int remainingHours = 24;
    if (createdAt != null) {
      final now = DateTime.now();
      final diff = now.difference(createdAt);
      if (diff.inMinutes < 60) {
        final m = diff.inMinutes.clamp(1, 59);
        timeAgo = 'منذ $m دقيقة';
      } else if (diff.inHours < 24) {
        timeAgo = 'منذ ${diff.inHours} ساعة';
      } else {
        timeAgo = 'منذ ${diff.inDays} يوم';
      }

      final windowEnd = createdAt.add(const Duration(hours: 48));
      final hoursLeft = windowEnd.difference(now).inHours;
      remainingHours = hoursLeft > 0 ? hoursLeft : 0;
    }

    final rawStatus = (json['status'] as String? ?? '').toLowerCase();
    BookingRequestStatus status = BookingRequestStatus.pending;
    if (rawStatus == 'accepted' || rawStatus == 'confirmed') {
      status = BookingRequestStatus.accepted;
    } else if (rawStatus == 'rejected' || rawStatus == 'cancelled') {
      status = BookingRequestStatus.rejected;
    }

    final itemIds = itemsToUse
        .map((i) => i['id']?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toList();

    return BookingRequestModel(
      id: json['id'] as String,
      code: code,
      customerName: customerName,
      customerAvatar: customerAvatar,
      customerPhone: customerPhone,
      location: location,
      timeAgo: timeAgo,
      remainingHours: remainingHours,
      eventType: json['event_type'] as String? ?? 'مناسبة خاصة',
      eventDate: eventDate,
      eventTime: eventTime,
      attendeesCount: (json['guest_count'] as num?)?.toInt() ?? 100,
      budget: budget,
      serviceName: serviceName,
      notes: json['notes'] as String? ?? '',
      status: status,
      customerId: json['customer_id'] as String?,
      bookingItemIds: itemIds,
      createdAt: createdAt,
    );
  }

  BookingRequestModel copyWith({
    String? id,
    String? code,
    String? customerName,
    String? customerAvatar,
    String? customerPhone,
    String? location,
    String? timeAgo,
    int? remainingHours,
    String? eventType,
    String? eventDate,
    String? eventTime,
    int? attendeesCount,
    double? budget,
    String? serviceName,
    String? notes,
    BookingRequestStatus? status,
    String? customerId,
    List<String>? bookingItemIds,
    DateTime? createdAt,
  }) {
    return BookingRequestModel(
      id: id ?? this.id,
      code: code ?? this.code,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      customerPhone: customerPhone ?? this.customerPhone,
      location: location ?? this.location,
      timeAgo: timeAgo ?? this.timeAgo,
      remainingHours: remainingHours ?? this.remainingHours,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      budget: budget ?? this.budget,
      serviceName: serviceName ?? this.serviceName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      bookingItemIds: bookingItemIds ?? this.bookingItemIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
