class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String? categoryId;
  final String? providerId;
  final String occasion;
  final double price;
  final String currency;
  final int executionTimeHours;
  final String description;
  final List<String> imageUrls;
  final bool isAvailable;
  final String? location;
  final int? capacity;
  final List<String> features;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    this.categoryId,
    this.providerId,
    required this.occasion,
    required this.price,
    this.currency = 'ر.ي',
    required this.executionTimeHours,
    required this.description,
    required this.imageUrls,
    this.isAvailable = true,
    this.location,
    this.capacity,
    this.features = const [],
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Collect all images (primary image + extra service images)
    final List<String> images = [];

    // 1. Primary image from service record
    if (json['image_url'] != null) {
      final singleUrl = json['image_url'].toString().trim();
      if (singleUrl.isNotEmpty && !images.contains(singleUrl)) {
        images.add(singleUrl);
      }
    }

    // 2. Extra images from service_images relation
    if (json['service_images'] is List) {
      final imgList = (json['service_images'] as List).toList();
      imgList.sort((a, b) {
        final aOrder = (a is Map ? a['sort_order'] : null) ?? 0;
        final bOrder = (b is Map ? b['sort_order'] : null) ?? 0;
        final numA = aOrder is num ? aOrder : (num.tryParse(aOrder.toString()) ?? 0);
        final numB = bOrder is num ? bOrder : (num.tryParse(bOrder.toString()) ?? 0);
        return numA.compareTo(numB);
      });
      for (final item in imgList) {
        if (item is Map && item['image_url'] != null) {
          final url = item['image_url'].toString().trim();
          if (url.isNotEmpty && !images.contains(url)) {
            images.add(url);
          }
        }
      }
    }

    // 3. Direct image lists if present
    if (json['image_urls'] is List) {
      for (final item in json['image_urls'] as List) {
        final url = item.toString().trim();
        if (url.isNotEmpty && !images.contains(url)) {
          images.add(url);
        }
      }
    } else if (json['images'] is List) {
      for (final item in json['images'] as List) {
        final url = item.toString().trim();
        if (url.isNotEmpty && !images.contains(url)) {
          images.add(url);
        }
      }
    }

    // Category name
    String catName = 'عام';
    if (json['categories'] is Map && json['categories']['name'] != null) {
      catName = json['categories']['name'].toString();
    } else if (json['category_name'] != null) {
      catName = json['category_name'].toString();
    } else if (json['category'] != null) {
      catName = json['category'].toString();
    }

    // Features
    List<String> feat = [];
    if (json['features'] is List) {
      feat = (json['features'] as List).map((e) => e.toString()).toList();
    }

    // Price
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    final statusStr = json['status']?.toString() ?? 'active';

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'خدمة بدون عنوان',
      category: catName,
      categoryId: json['category_id']?.toString(),
      providerId: json['provider_id']?.toString(),
      occasion: json['occasion'] as String? ?? 'حفلات ومناسبات',
      price: parsedPrice,
      currency: json['currency'] == 'YER' ? 'ر.ي' : (json['currency'] as String? ?? 'ر.ي'),
      executionTimeHours: json['capacity'] as int? ?? (json['execution_time_hours'] as int? ?? 4),
      description: json['description'] as String? ?? '',
      imageUrls: images,
      isAvailable: statusStr == 'active',
      location: json['location'] as String?,
      capacity: json['capacity'] as int?,
      features: feat,
      status: statusStr,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson({String? forProviderId, String? forCategoryId}) {
    return {
      if (forProviderId != null || providerId != null)
        'provider_id': forProviderId ?? providerId,
      if (forCategoryId != null || categoryId != null)
        'category_id': forCategoryId ?? categoryId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency == 'ر.ي' ? 'YER' : currency,
      if (imageUrls.isNotEmpty) 'image_url': imageUrls.first,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (capacity != null) 'capacity': capacity,
      'features': features,
      'status': isAvailable ? 'active' : 'inactive',
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? categoryId,
    String? providerId,
    String? occasion,
    double? price,
    String? currency,
    int? executionTimeHours,
    String? description,
    List<String>? imageUrls,
    bool? isAvailable,
    String? location,
    int? capacity,
    List<String>? features,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      providerId: providerId ?? this.providerId,
      occasion: occasion ?? this.occasion,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      executionTimeHours: executionTimeHours ?? this.executionTimeHours,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      features: features ?? this.features,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
