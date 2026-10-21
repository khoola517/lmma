import 'package:flutter/material.dart';
import '../data/mock/provider_mock_data.dart';
import '../models/provider_profile_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';

class ProfileProvider extends ChangeNotifier {
  late ProviderProfileModel _profile;
  List<ReviewModel> _reviews = [];
  List<NotificationModel> _notifications = [];
  double? _ratingFilter;

  ProfileProvider() {
    _profile = ProviderMockData.initialProfile;
    _reviews = List.from(ProviderMockData.initialReviews);
    _notifications = List.from(ProviderMockData.initialNotifications);
  }

  // Profile
  ProviderProfileModel get profile => _profile;

  void updateProfile({
    required String businessName,
    required String phone,
    required String email,
    required String location,
    required String category,
    required String bio,
  }) {
    _profile = _profile.copyWith(
      businessName: businessName,
      phone: phone,
      email: email,
      location: location,
      category: category,
      bio: bio,
    );
    notifyListeners();
  }

  // Reviews
  List<ReviewModel> get reviews {
    if (_ratingFilter == null) return _reviews;
    return _reviews.where((r) => r.rating >= _ratingFilter!).toList();
  }

  int get totalReviewsCount => _reviews.length;
  double get averageRating => _profile.overallRating;

  int get fiveStarCount => _reviews.where((r) => r.rating == 5.0).length;

  void setRatingFilter(double? rating) {
    _ratingFilter = rating;
    notifyListeners();
  }

  void replyToReview(String reviewId, String reply) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index].providerReply = reply;
      notifyListeners();
    }
  }

  // Notifications
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }
}
