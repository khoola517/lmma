enum ConfirmedBookingStatus {
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class ConfirmedBookingModel {
  final String id;
  final String bookingNumber; // e.g. BK-2041 or KH-26-10002
  final String customerName;
  final String customerPhone;
  final String customerLocation;
  final String serviceName;
  final String eventType;
  final String eventDate;
  final String eventDateString;
  final String eventTime;
  final double totalAmount;
  final String notes;
  ConfirmedBookingStatus status;
  final String? customerId;
  final List<String> bookingItemIds;
  final DateTime? createdAt;

  ConfirmedBookingModel({
    required this.id,
    required this.bookingNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerLocation,
    required this.serviceName,
    required this.eventType,
    required this.eventDate,
    required this.eventDateString,
    required this.eventTime,
    required this.totalAmount,
    required this.notes,
    this.status = ConfirmedBookingStatus.confirmed,
    this.customerId,
    this.bookingItemIds = const [],
    this.createdAt,
  });

  factory ConfirmedBookingModel.fromJson(
    Map<String, dynamic> json, {
    String? targetProviderId,
  }) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final customerName = customer?['full_name'] as String? ?? 'عميل خِدمتي';
    final customerPhone = customer?['phone'] as String? ?? 'غير متوفر';

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

    String customerLocation = json['event_location'] as String? ?? '';
    if (customerLocation.isEmpty) {
      final firstService = itemsToUse.isNotEmpty
          ? itemsToUse.first['services'] as Map<String, dynamic>?
          : null;
      final firstServiceLoc = firstService?['location'] as String?;
      customerLocation = firstServiceLoc ?? 'صنعاء';
    }

    final double totalAmount = (targetProviderId != null && relevantItems.isNotEmpty)
        ? relevantItems.fold<double>(
            0.0,
            (sum, i) =>
                sum +
                ((i['subtotal'] as num?)?.toDouble() ??
                    ((i['unit_price'] as num?)?.toDouble() ?? 0.0)),
          )
        : ((json['total_amount'] as num?)?.toDouble() ??
            (json['budget'] as num?)?.toDouble() ??
            itemsToUse.fold<double>(
              0.0,
              (sum, i) => sum + ((i['subtotal'] as num?)?.toDouble() ?? 0.0),
            ));

    final rawCode = json['booking_code']?.toString() ??
        'BK-${json['id'].toString().substring(0, 4)}';
    final bookingNumber = rawCode.replaceAll('#', '');

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

    ConfirmedBookingStatus status;
    final rawStatus = (json['status'] as String? ?? '').toLowerCase();
    switch (rawStatus) {
      case 'in_progress':
      case 'inprogress':
        status = ConfirmedBookingStatus.inProgress;
        break;
      case 'completed':
        status = ConfirmedBookingStatus.completed;
        break;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        status = ConfirmedBookingStatus.cancelled;
        break;
      case 'confirmed':
      default:
        status = ConfirmedBookingStatus.confirmed;
        break;
    }

    final itemIds = itemsToUse
        .map((i) => i['id']?.toString())
        .where((id) => id != null)
        .cast<String>()
        .toList();

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    return ConfirmedBookingModel(
      id: json['id'] as String,
      bookingNumber: bookingNumber,
      customerName: customerName,
      customerPhone: customerPhone,
      customerLocation: customerLocation,
      serviceName: serviceName,
      eventType: json['event_type'] as String? ?? 'مناسبة خاصة',
      eventDate: eventDate,
      eventDateString: eventDate,
      eventTime: eventTime,
      totalAmount: totalAmount,
      notes: json['notes'] as String? ?? '',
      status: status,
      customerId: json['customer_id'] as String?,
      bookingItemIds: itemIds,
      createdAt: createdAt,
    );
  }

  ConfirmedBookingModel copyWith({
    String? id,
    String? bookingNumber,
    String? customerName,
    String? customerPhone,
    String? customerLocation,
    String? serviceName,
    String? eventType,
    String? eventDate,
    String? eventDateString,
    String? eventTime,
    double? totalAmount,
    String? notes,
    ConfirmedBookingStatus? status,
    String? customerId,
    List<String>? bookingItemIds,
    DateTime? createdAt,
  }) {
    return ConfirmedBookingModel(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerLocation: customerLocation ?? this.customerLocation,
      serviceName: serviceName ?? this.serviceName,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      eventDateString: eventDateString ?? this.eventDateString,
      eventTime: eventTime ?? this.eventTime,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      bookingItemIds: bookingItemIds ?? this.bookingItemIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
