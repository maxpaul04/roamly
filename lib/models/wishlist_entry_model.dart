class WishlistEntry {
  static const int UNSAVED_ID = 0;

  final int id;
  final String userId;
  final String cityName;
  final String country;
  final String continent;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  WishlistEntry({
    required this.id,
    required this.userId,
    required this.cityName,
    required this.country,
    required this.continent,
    required this.latitude,
    required this.longitude,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cityName': cityName,
      'country': country,
      'continent': continent,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WishlistEntry.fromMap(Map<String, dynamic> map) {
    return WishlistEntry(
      id: map['id'] as int,
      userId: map['userId'] as String,
      cityName: map['cityName'] as String,
      country: map['country'] as String,
      continent: map['continent'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}