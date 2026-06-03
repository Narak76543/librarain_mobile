class ReviewModel {
  ReviewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.text,
  });

  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String text;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'Anonymous',
      userAvatar: json['user_avatar']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      date: json['date']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}
