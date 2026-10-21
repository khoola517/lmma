class ReviewModel {
  final String id;
  final String customerName;
  final String customerAvatar;
  final double rating;
  final String date;
  final String serviceName;
  final String comment;
  String? providerReply;

  ReviewModel({
    required this.id,
    required this.customerName,
    required this.customerAvatar,
    required this.rating,
    required this.date,
    required this.serviceName,
    required this.comment,
    this.providerReply,
  });
}
