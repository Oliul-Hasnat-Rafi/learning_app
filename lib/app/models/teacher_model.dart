class TeacherModel {
  final String id;
  final String userId;
  final List<String> languages;
  final String bio;
  final double hourlyRate;
  final List<String> availability; // Stored as ISO date strings
  final double rating;
  final int totalReviews;

  TeacherModel({
    required this.id,
    required this.userId,
    required this.languages,
    required this.bio,
    required this.hourlyRate,
    required this.availability,
    this.rating = 0.0,
    this.totalReviews = 0,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      userId: json['userId'],
      languages: List<String>.from(json['languages']),
      bio: json['bio'],
      hourlyRate: json['hourlyRate'].toDouble(),
      availability: List<String>.from(json['availability']),
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'languages': languages,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'availability': availability,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}