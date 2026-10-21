enum BookingRequestStatus {
  pending,
  accepted,
  rejected,
}

class BookingRequestModel {
  final String id;
  final String code; // e.g. #BK-8902
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
  });
}
