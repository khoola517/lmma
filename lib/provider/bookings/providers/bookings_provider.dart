import 'package:flutter/material.dart';
import 'package:khadematy_web/core/config/supabase_config.dart';
import 'package:khadematy_web/core/services/supabase_realtime_service.dart';
import 'package:khadematy_web/data/mock/provider_mock_data.dart';
import 'package:khadematy_web/provider/bookings/models/booking_request_model.dart';
import 'package:khadematy_web/provider/bookings/models/confirmed_booking_model.dart';

class BookingsProvider extends ChangeNotifier {
  List<BookingRequestModel> _bookingRequests = [];
  List<ConfirmedBookingModel> _confirmedBookings = [];
  String _confirmedSearchQuery = '';
  String _requestSearchQuery = '';
  ConfirmedBookingStatus? _confirmedStatusFilter;

  bool _isLoading = false;
  String? _errorMessage;
  String? _lastLoadedProviderId;
  String? _activeActionBookingId;
  final List<RealtimeSubscriptionToken> _realtimeTokens = [];

  BookingsProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    // 1. الاستماع لتحديثات الحجوزات لحظياً
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'bookings',
        onInserted: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
        onUpdated: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
        onDeleted: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
      ),
    );

    // 2. الاستماع لتحديثات عناصر الحجز لحظياً
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'booking_items',
        onInserted: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
        onUpdated: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
        onDeleted: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
      ),
    );

    // 3. الاستماع لتحديثات سجل حالات الحجز لحظياً
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.subscribeTable(
        table: 'booking_status_history',
        onInserted: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
        onUpdated: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
        onDeleted: (_) => loadBookings(providerId: _lastLoadedProviderId, force: true),
      ),
    );

    // 3. إعادة المزامنة عند استعادة الاتصال
    _realtimeTokens.add(
      SupabaseRealtimeService.instance.onReconnected(() {
        loadBookings(providerId: _lastLoadedProviderId, force: true);
      }),
    );
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ConfirmedBookingStatus? get confirmedStatusFilter => _confirmedStatusFilter;
  String get confirmedSearchQuery => _confirmedSearchQuery;
  String get requestSearchQuery => _requestSearchQuery;
  String? get activeActionBookingId => _activeActionBookingId;
  String? get lastLoadedProviderId => _lastLoadedProviderId;
  bool isActionLoading(String id) => _activeActionBookingId == id;

  // Booking Requests
  List<BookingRequestModel> get pendingRequests {
    return _bookingRequests.where((r) {
      final isPending = r.status == BookingRequestStatus.pending;
      if (!isPending) return false;

      if (_requestSearchQuery.isEmpty) return true;
      final q = _requestSearchQuery.toLowerCase();
      return r.customerName.toLowerCase().contains(q) ||
          r.code.toLowerCase().contains(q) ||
          r.serviceName.toLowerCase().contains(q) ||
          r.eventType.toLowerCase().contains(q);
    }).toList();
  }

  int get pendingRequestsCount =>
      _bookingRequests.where((r) => r.status == BookingRequestStatus.pending).length;

  // Confirmed Bookings
  List<ConfirmedBookingModel> get confirmedBookings {
    return _confirmedBookings.where((b) {
      final matchesSearch = _confirmedSearchQuery.isEmpty ||
          b.customerName.toLowerCase().contains(_confirmedSearchQuery.toLowerCase()) ||
          b.bookingNumber.toLowerCase().contains(_confirmedSearchQuery.toLowerCase()) ||
          b.serviceName.toLowerCase().contains(_confirmedSearchQuery.toLowerCase()) ||
          b.customerPhone.contains(_confirmedSearchQuery) ||
          b.eventType.toLowerCase().contains(_confirmedSearchQuery.toLowerCase());

      final matchesStatus =
          _confirmedStatusFilter == null || b.status == _confirmedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalConfirmedCount => _confirmedBookings.length;
  int get inProgressCount =>
      _confirmedBookings.where((b) => b.status == ConfirmedBookingStatus.inProgress).length;
  int get completedCount =>
      _confirmedBookings.where((b) => b.status == ConfirmedBookingStatus.completed).length;
  int get cancelledCount =>
      _confirmedBookings.where((b) => b.status == ConfirmedBookingStatus.cancelled).length;

  /// إجمالي الإيرادات المحققة والمعتمدة من كافة الحجوزات النشطة وغير الملغاة
  double get totalRevenue {
    return _confirmedBookings
        .where((b) => b.status != ConfirmedBookingStatus.cancelled)
        .fold<double>(0.0, (sum, b) => sum + b.totalAmount);
  }

  /// معدل قبول الحجوزات من 0.0 إلى 1.0 محسوب ديناميكياً
  double get acceptanceRate {
    final confirmed = _confirmedBookings
        .where((b) => b.status != ConfirmedBookingStatus.cancelled)
        .length;
    final total = confirmed + _bookingRequests.length;
    if (total == 0) return 1.0;
    return (confirmed / total).clamp(0.0, 1.0);
  }

  void setConfirmedSearchQuery(String query) {
    _confirmedSearchQuery = query.trim();
    notifyListeners();
  }

  void setRequestSearchQuery(String query) {
    _requestSearchQuery = query.trim();
    notifyListeners();
  }

  void setConfirmedStatusFilter(ConfirmedBookingStatus? status) {
    _confirmedStatusFilter = status;
    notifyListeners();
  }

  /// تحميل جميع الحجوزات وطلبات الحجز من Supabase
  Future<void> loadBookings({String? providerId, bool force = false}) async {
    if (_isLoading && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. تحديد معرّف المزود المستهدف
      String? resolvedProviderId = providerId ?? _lastLoadedProviderId;
      if (resolvedProviderId == null || resolvedProviderId.isEmpty) {
        final user = SupabaseConfig.client.auth.currentUser;
        if (user != null) {
          try {
            final prov = await SupabaseConfig.client
                .from('provider_profiles')
                .select('id')
                .eq('user_id', user.id)
                .maybeSingle();
            if (prov != null) {
              resolvedProviderId = prov['id'] as String?;
            }
          } catch (e) {
            debugPrint('Note: Error fetching provider profile for user: $e');
          }
        }
      }

      _lastLoadedProviderId = resolvedProviderId;

      // 2. جلب الحجوزات مع تفاصيل العميل والخدمات
      final response = await SupabaseConfig.client
          .from('bookings')
          .select('''
            id,
            booking_code,
            customer_id,
            package_id,
            event_type,
            event_date,
            time_slot,
            event_location,
            guest_count,
            budget,
            total_amount,
            status,
            notes,
            created_at,
            updated_at,
            customer:profiles!customer_id (id, full_name, phone, avatar_url),
            booking_items (
              id,
              booking_id,
              service_id,
              quantity,
              unit_price,
              subtotal,
              item_status,
              rejection_reason,
              responded_at,
              created_at,
              services (
                id,
                name,
                provider_id,
                location,
                price
              )
            )
          ''')
          .order('created_at', ascending: false);

      final rawList = List<Map<String, dynamic>>.from(response as List);

      // 3. تصفية الحجوزات بدقة متناهية حسب مزود الخدمة
      List<Map<String, dynamic>> providerBookings = [];
      if (resolvedProviderId != null && resolvedProviderId.isNotEmpty) {
        providerBookings = rawList.where((raw) {
          final items = (raw['booking_items'] as List?) ?? [];
          return items.any((bi) {
            final service = bi['services'] as Map<String, dynamic>?;
            return service?['provider_id'] == resolvedProviderId;
          });
        }).toList();
      } else {
        providerBookings = rawList;
      }

      final List<BookingRequestModel> requests = [];
      final List<ConfirmedBookingModel> confirmed = [];

      for (final raw in providerBookings) {
        final statusStr = (raw['status'] as String? ?? 'pending').toLowerCase();
        if (statusStr == 'pending') {
          requests.add(
            BookingRequestModel.fromJson(raw, targetProviderId: resolvedProviderId),
          );
        } else {
          confirmed.add(
            ConfirmedBookingModel.fromJson(raw, targetProviderId: resolvedProviderId),
          );
        }
      }

      _bookingRequests = requests;
      _confirmedBookings = confirmed;
    } catch (e) {
      debugPrint('Error loading bookings from Supabase: $e');
      _errorMessage = 'تعذر الاتصال بـ Supabase لجلب الحجوزات: $e';

      // Fallback إلى البيانات المبدئية فقط عند عدم الاتصال بالسيرفر إطلاقاً
      if (!SupabaseConfig.hasClient && _bookingRequests.isEmpty && _confirmedBookings.isEmpty) {
        _bookingRequests = List.from(ProviderMockData.initialBookingRequests);
        _confirmedBookings = List.from(ProviderMockData.initialConfirmedBookings);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// قبول وتأكيد طلب حجز من العميل في Supabase وتحديث الحالة محلياً
  Future<bool> acceptBookingRequest(String requestId) async {
    _activeActionBookingId = requestId;
    _errorMessage = null;
    notifyListeners();

    try {
      final nowIso = DateTime.now().toIso8601String();
      final bool isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(requestId);

      final index = _bookingRequests.indexWhere((r) => r.id == requestId);
      final targetReq = index != -1 ? _bookingRequests[index] : null;

      // 1. تحديث Supabase أولاً والتأكد من نجاح العملية على الخادم
      if (isUuid) {
        if (targetReq != null && targetReq.bookingItemIds.isNotEmpty) {
          await SupabaseConfig.client.from('booking_items').update({
            'item_status': 'accepted',
            'responded_at': nowIso,
          }).inFilter('id', targetReq.bookingItemIds);
        } else {
          await SupabaseConfig.client.from('booking_items').update({
            'item_status': 'accepted',
            'responded_at': nowIso,
          }).eq('booking_id', requestId);
        }

        // تحديث جدول bookings
        await SupabaseConfig.client.from('bookings').update({
          'status': 'confirmed',
          'updated_at': nowIso,
        }).eq('id', requestId);

        // إشعار العميل (اختياري)
        if (targetReq != null && targetReq.customerId != null) {
          try {
            await SupabaseConfig.client.from('notifications').insert({
              'user_id': targetReq.customerId,
              'title': 'تم تأكيد حجزك بنجاح',
              'body': 'وافق مقدم الخدمة على حجزك رقم #${targetReq.code}',
              'type': 'booking_confirmed',
              'related_booking_id': requestId,
              'created_at': nowIso,
            });
          } catch (ne) {
            debugPrint('Note: Notification insert note: $ne');
          }
        }
      }

      // 2. تحديث الحالة محلياً فور نجاح الخادم
      if (index != -1 && targetReq != null) {
        _bookingRequests.removeAt(index);
        targetReq.status = BookingRequestStatus.accepted;

        _confirmedBookings.insert(
          0,
          ConfirmedBookingModel(
            id: targetReq.id,
            bookingNumber: targetReq.code.replaceAll('#', ''),
            customerName: targetReq.customerName,
            customerPhone: targetReq.customerPhone,
            customerLocation: targetReq.location,
            serviceName: targetReq.serviceName,
            eventType: targetReq.eventType,
            eventDate: targetReq.eventDate,
            eventDateString: targetReq.eventDate,
            eventTime: targetReq.eventTime,
            totalAmount: targetReq.budget,
            notes: targetReq.notes,
            status: ConfirmedBookingStatus.confirmed,
            customerId: targetReq.customerId,
            bookingItemIds: targetReq.bookingItemIds,
            createdAt: targetReq.createdAt,
          ),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Unexpected error accepting booking request: $e');
      _errorMessage = 'تعذر قبول الحجز في Supabase: $e';
      notifyListeners();
      return false;
    } finally {
      _activeActionBookingId = null;
      notifyListeners();
    }
  }

  /// رفض طلب حجز مع تدوين السبب في Supabase
  Future<bool> rejectBookingRequest(String requestId, {String? reason}) async {
    _activeActionBookingId = requestId;
    _errorMessage = null;
    notifyListeners();

    try {
      final nowIso = DateTime.now().toIso8601String();
      final bool isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(requestId);

      final index = _bookingRequests.indexWhere((r) => r.id == requestId);
      final req = index != -1 ? _bookingRequests[index] : null;

      // 1. تحديث Supabase أولاً
      if (isUuid) {
        if (req != null && req.bookingItemIds.isNotEmpty) {
          await SupabaseConfig.client.from('booking_items').update({
            'item_status': 'rejected',
            if (reason != null && reason.isNotEmpty) 'rejection_reason': reason,
            'responded_at': nowIso,
          }).inFilter('id', req.bookingItemIds);
        } else {
          await SupabaseConfig.client.from('booking_items').update({
            'item_status': 'rejected',
            if (reason != null && reason.isNotEmpty) 'rejection_reason': reason,
            'responded_at': nowIso,
          }).eq('booking_id', requestId);
        }

        await SupabaseConfig.client.from('bookings').update({
          'status': 'cancelled',
          'updated_at': nowIso,
        }).eq('id', requestId);

        if (req != null && req.customerId != null) {
          try {
            await SupabaseConfig.client.from('notifications').insert({
              'user_id': req.customerId,
              'title': 'تم الاعتذار عن طلب الحجز',
              'body': 'اعتذر مقدم الخدمة عن طلب الحجز رقم #${req.code}${reason != null && reason.isNotEmpty ? ': $reason' : ''}',
              'type': 'booking_cancelled',
              'related_booking_id': requestId,
              'created_at': nowIso,
            });
          } catch (ne) {
            debugPrint('Note: Notification insert error on reject: $ne');
          }
        }
      }

      // 2. تحديث الحالة محلياً فور نجاح الخادم
      if (index != -1 && req != null) {
        _bookingRequests.removeAt(index);
        req.status = BookingRequestStatus.rejected;

        _confirmedBookings.insert(
          0,
          ConfirmedBookingModel(
            id: req.id,
            bookingNumber: req.code.replaceAll('#', ''),
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
            status: ConfirmedBookingStatus.cancelled,
            customerId: req.customerId,
            bookingItemIds: req.bookingItemIds,
            createdAt: req.createdAt,
          ),
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Unexpected error rejecting booking request: $e');
      _errorMessage = 'تعذر رفض الحجز في Supabase: $e';
      notifyListeners();
      return false;
    } finally {
      _activeActionBookingId = null;
      notifyListeners();
    }
  }

  /// تحديث حالة حجز مؤكد (قيد التنفيذ / مكتمل / ملغي) في Supabase ومحلياً
  Future<bool> updateBookingStatus(
    String bookingId,
    ConfirmedBookingStatus status,
  ) async {
    _activeActionBookingId = bookingId;
    _errorMessage = null;
    notifyListeners();

    try {
      String dbStatus;
      switch (status) {
        case ConfirmedBookingStatus.inProgress:
          dbStatus = 'in_progress';
          break;
        case ConfirmedBookingStatus.completed:
          dbStatus = 'completed';
          break;
        case ConfirmedBookingStatus.cancelled:
          dbStatus = 'cancelled';
          break;
        case ConfirmedBookingStatus.confirmed:
        default:
          dbStatus = 'confirmed';
          break;
      }

      final nowIso = DateTime.now().toIso8601String();
      final bool isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(bookingId);

      // تحديث Supabase
      if (isUuid) {
        await SupabaseConfig.client.from('bookings').update({
          'status': dbStatus,
          'updated_at': nowIso,
        }).eq('id', bookingId);

        if (status == ConfirmedBookingStatus.cancelled) {
          await SupabaseConfig.client.from('booking_items').update({
            'item_status': 'rejected',
            'responded_at': nowIso,
          }).eq('booking_id', bookingId);
        }

        final targetIndex = _confirmedBookings.indexWhere((b) => b.id == bookingId);
        final target = targetIndex != -1 ? _confirmedBookings[targetIndex] : null;
        if (target != null && target.customerId != null && target.customerId!.isNotEmpty) {
          try {
            String statusTitle = 'تحديث في حالة الحجز';
            String statusDesc = 'تم تحديث حالة حجزك رقم #${target.bookingNumber} إلى ';
            switch (status) {
              case ConfirmedBookingStatus.inProgress:
                statusDesc += 'قيد التنفيذ حالياً';
                break;
              case ConfirmedBookingStatus.completed:
                statusTitle = 'اكتملت الخدمة بنجاح';
                statusDesc += 'مكتمل بنجاح، شكراً لاختياركم خِدمتي';
                break;
              case ConfirmedBookingStatus.cancelled:
                statusTitle = 'إلغاء الحجز';
                statusDesc += 'ملغي';
                break;
              default:
                statusDesc += 'مؤكد';
            }
            await SupabaseConfig.client.from('notifications').insert({
              'user_id': target.customerId,
              'title': statusTitle,
              'body': statusDesc,
              'type': 'booking_status_updated',
              'related_booking_id': bookingId,
              'created_at': nowIso,
            });
          } catch (_) {}
        }
      }

      // تحديث الحالة محلياً
      final index = _confirmedBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _confirmedBookings[index].status = status;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Unexpected error updating booking status: $e');
      _errorMessage = 'تعذر تحديث حالة الحجز: $e';
      notifyListeners();
      return false;
    } finally {
      _activeActionBookingId = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final token in _realtimeTokens) {
      token.cancel();
    }
    _realtimeTokens.clear();
    super.dispose();
  }
}