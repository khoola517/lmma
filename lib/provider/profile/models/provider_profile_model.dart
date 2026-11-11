import 'package:khadematy_web/provider/settings/models/provider_settings_model.dart';

class ProviderProfileModel {
  String? id;
  String? userId;
  String businessName;
  String phone;
  String email;
  String location;
  String category;
  String bio;
  String? logoUrl;
  bool isVerified;
  double overallRating;
  int completedBookingsCount;
  ProviderSettingsModel settings;

  ProviderProfileModel({
    this.id,
    this.userId,
    required this.businessName,
    required this.phone,
    required this.email,
    required this.location,
    required this.category,
    required this.bio,
    this.logoUrl,
    this.isVerified = true,
    this.overallRating = 5.0,
    this.completedBookingsCount = 0,
    this.settings = const ProviderSettingsModel(),
  });

  factory ProviderProfileModel.fromSupabase({
    required Map<String, dynamic> providerProfile,
    Map<String, dynamic>? userProfile,
    double? rating,
    int? completedCount,
    String? categoryName,
  }) {
    final status = providerProfile['status'] as String? ?? 'pending';
    final resolvedCategory = (providerProfile['category'] as String?)?.isNotEmpty == true
        ? providerProfile['category'] as String
        : (categoryName?.isNotEmpty == true ? categoryName! : 'تنظيم وتنسيق الحفلات');

    final rawSettings = providerProfile['settings'] as Map<String, dynamic>?;

    return ProviderProfileModel(
      id: providerProfile['id'] as String?,
      userId: providerProfile['user_id'] as String?,
      businessName: providerProfile['business_name'] as String? ??
          userProfile?['full_name'] as String? ??
          'مقدم خدمة خِدمتي',
      phone: userProfile?['phone'] as String? ?? '',
      email: userProfile?['email'] as String? ?? '',
      location: providerProfile['address'] as String? ?? '',
      category: resolvedCategory,
      bio: providerProfile['description'] as String? ?? '',
      logoUrl: providerProfile['logo_url'] as String? ??
          userProfile?['avatar_url'] as String?,
      isVerified: status == 'approved',
      overallRating: rating ?? 5.0,
      completedBookingsCount: completedCount ?? 0,
      settings: ProviderSettingsModel.fromJson(rawSettings),
    );
  }

  ProviderProfileModel copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? phone,
    String? email,
    String? location,
    String? category,
    String? bio,
    String? logoUrl,
    bool? isVerified,
    double? overallRating,
    int? completedBookingsCount,
    ProviderSettingsModel? settings,
  }) {
    return ProviderProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      category: category ?? this.category,
      bio: bio ?? this.bio,
      logoUrl: logoUrl ?? this.logoUrl,
      isVerified: isVerified ?? this.isVerified,
      overallRating: overallRating ?? this.overallRating,
      completedBookingsCount: completedBookingsCount ?? this.completedBookingsCount,
      settings: settings ?? this.settings,
    );
  }
}

