class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
    };
  }
}

class Recommendation {
  final String id;
  final String serviceType;
  final String title;
  final String tagLabel;
  final String tagColor;
  final double rating;
  final int reviews;
  final String price;
  final String image;

  Recommendation({
    required this.id,
    required this.serviceType,
    required this.title,
    required this.tagLabel,
    required this.tagColor,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'].toString(),
      serviceType: json['serviceType'] ?? json['service_type'] ?? '',
      title: json['title'] as String,
      tagLabel: json['tagLabel'] ?? json['tag_label'] ?? '',
      tagColor: json['tagColor'] ?? json['tag_color'] ?? 'bg-teal-600',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      price: json['price'] as String,
      image: json['image'] as String,
    );
  }
}
