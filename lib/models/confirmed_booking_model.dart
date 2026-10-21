enum ConfirmedBookingStatus {
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class ConfirmedBookingModel {
  final String id;
  final String bookingNumber; // e.g. BK-2041
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
  });
}
