class ProviderProfileModel {
  String businessName;
  String phone;
  String email;
  String location;
  String category;
  String bio;
  bool isVerified;
  double overallRating;
  int completedBookingsCount;

  ProviderProfileModel({
    required this.businessName,
    required this.phone,
    required this.email,
    required this.location,
    required this.category,
    required this.bio,
    this.isVerified = true,
    this.overallRating = 4.9,
    this.completedBookingsCount = 128,
  });

  ProviderProfileModel copyWith({
    String? businessName,
    String? phone,
    String? email,
    String? location,
    String? category,
    String? bio,
    bool? isVerified,
    double? overallRating,
    int? completedBookingsCount,
  }) {
    return ProviderProfileModel(
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      category: category ?? this.category,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      overallRating: overallRating ?? this.overallRating,
      completedBookingsCount: completedBookingsCount ?? this.completedBookingsCount,
    );
  }
}
