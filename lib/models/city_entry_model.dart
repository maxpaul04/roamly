class CityEntry {
  static const int UNSAVED_ID = 0;

  final int id;
  final String userId;
  final String userName;
  final String name;
  final String country;
  final String continent;
  final DateTime arrivalDate;
  final DateTime departureDate;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final String? imagePath;

  CityEntry({
    required this.id,
    required this.userId,
    required this.userName,
    required this.name,
    required this.country,
    required this.continent,
    required this.arrivalDate,
    required this.departureDate,
    required this.rating,
    this.comment,
    DateTime? createdAt,
    required this.latitude,
    required this.longitude,
    this.imagePath,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'name': name,
      'country': country,
      'continent': continent,
      'arrivalDate': arrivalDate.toIso8601String(),
      'departureDate': departureDate.toIso8601String(),
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
    };
  }

  factory CityEntry.fromMap(Map<String, dynamic> map) {
    return CityEntry(
      id: map['id'] as int,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      continent: map['continent'] as String? ?? 'Unknown',
      arrivalDate: DateTime.parse(map['arrivalDate'] as String),
      departureDate: DateTime.parse(map['departureDate'] as String),
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      imagePath: map['imagePath'] as String?,
    );
  }

  CityEntry copyWith({
    int? id,
    String? userName,
    DateTime? arrivalDate,
    DateTime? departureDate,
    double? rating,
    String? comment,
    String? imagePath,
  }) {
    return CityEntry(
      id: id ?? this.id,
      userId: userId,
      userName: userName ?? this.userName,
      name: name,
      country: country,
      continent: continent,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
