class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String occasion;
  final double price;
  final int executionTimeHours;
  final String description;
  final List<String> imageUrls;
  final bool isAvailable;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.occasion,
    required this.price,
    required this.executionTimeHours,
    required this.description,
    required this.imageUrls,
    this.isAvailable = true,
  });

  ServiceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? occasion,
    double? price,
    int? executionTimeHours,
    String? description,
    List<String>? imageUrls,
    bool? isAvailable,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      occasion: occasion ?? this.occasion,
      price: price ?? this.price,
      executionTimeHours: executionTimeHours ?? this.executionTimeHours,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
