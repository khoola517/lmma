import 'package:flutter/material.dart';
import '../data/mock/provider_mock_data.dart';
import '../models/booking_request_model.dart';
import '../models/confirmed_booking_model.dart';

class BookingsProvider extends ChangeNotifier {
  List<BookingRequestModel> _bookingRequests = [];
  List<ConfirmedBookingModel> _confirmedBookings = [];
  String _confirmedSearchQuery = '';
  ConfirmedBookingStatus? _confirmedStatusFilter;

  BookingsProvider() {
    _bookingRequests = List.from(ProviderMockData.initialBookingRequests);
    _confirmedBookings = List.from(ProviderMockData.initialConfirmedBookings);
  }

  // Booking Requests
  List<BookingRequestModel> get pendingRequests =>
      _bookingRequests.where((r) => r.status == BookingRequestStatus.pending).toList();

  int get pendingRequestsCount => pendingRequests.length;

  void acceptBookingRequest(String requestId) {
    final index = _bookingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _bookingRequests[index];
      req.status = BookingRequestStatus.accepted;

      // Add to confirmed bookings
      _confirmedBookings.insert(
        0,
        ConfirmedBookingModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookingNumber: 'BK-${req.code.replaceAll(RegExp(r'[^0-9]'), '')}',
          customerName: req.customerName,
          customerPhone: req.customerPhone,
          customerLocation: req.location,
          serviceName: req.serviceName,
          eventType: req.eventType,
          eventDate: req.eventDate,
          eventDateString: req.eventDate,
          eventTime: req.eventTime,
          totalAmount: req.budget,
          notes: req.notes,
          status: ConfirmedBookingStatus.confirmed,
        ),
      );
      notifyListeners();
    }
  }

  void rejectBookingRequest(String requestId) {
    final index = _bookingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _bookingRequests[index].status = BookingRequestStatus.rejected;
      notifyListeners();
    }
  }

  // Confirmed Bookings
  List<ConfirmedBookingModel> get confirmedBookings {
    return _confirmedBookings.where((b) {
      final matchesSearch = _confirmedSearchQuery.isEmpty ||
          b.customerName.contains(_confirmedSearchQuery) ||
          b.bookingNumber.toLowerCase().contains(_confirmedSearchQuery.toLowerCase()) ||
          b.serviceName.contains(_confirmedSearchQuery);
      final matchesStatus = _confirmedStatusFilter == null || b.status == _confirmedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalConfirmedCount => _confirmedBookings.length;
  int get inProgressCount =>
      _confirmedBookings.where((b) => b.status == ConfirmedBookingStatus.inProgress).length;
  int get completedCount =>
      _confirmedBookings.where((b) => b.status == ConfirmedBookingStatus.completed).length;

  void setConfirmedSearchQuery(String query) {
    _confirmedSearchQuery = query.trim();
    notifyListeners();
  }

  void setConfirmedStatusFilter(ConfirmedBookingStatus? status) {
    _confirmedStatusFilter = status;
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, ConfirmedBookingStatus status) {
    final index = _confirmedBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _confirmedBookings[index].status = status;
      notifyListeners();
    }
  }
}
