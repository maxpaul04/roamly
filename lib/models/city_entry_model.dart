class CityEntry {
  static const int UNSAVED_ID = 0;

  final int id;
  final String userId;
  final String name;
  final String country;
  final DateTime arrivalDate;
  final DateTime departureDate;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final String? pictureUrl;

  CityEntry({
    required this.id,
    required this.userId,
    required this.name,
    required this.country,
    required this.arrivalDate,
    required this.departureDate,
    required this.rating,
    this.comment,
    DateTime? createdAt,
    required this.latitude,
    required this.longitude,
    this.pictureUrl,

  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'country': country,
      'arrivalDate': arrivalDate.toIso8601String(),
      'departureDate': departureDate.toIso8601String(),
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'pictureUrl': pictureUrl,
    };
  }

  factory CityEntry.fromMap(Map<String, dynamic> map) {
    return CityEntry(
      id: map['id'] as int,
      userId: map['userId'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      arrivalDate: DateTime.parse(map['arrivalDate'] as String),
      departureDate: DateTime.parse(map['departureDate'] as String),
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      pictureUrl: map['pictureUrl'] as String?,
    );
  }

  CityEntry copyWith({
    int? id,
    DateTime? arrivalDate,
    DateTime? departureDate,
    double? rating,
    String? comment,
    String? pictureUrl,
  }) {
    return CityEntry(
      id: id ?? this.id,
      userId: userId,
      name: name,
      country: country,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      latitude: latitude,
      longitude: longitude,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }
}