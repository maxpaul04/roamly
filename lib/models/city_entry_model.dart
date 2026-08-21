class CityEntry {
  static const int UNSAVED_ID = 0;

  final int id;
  final String userId;
  final String name;
  final String country;
  final DateTime arrivalDate;
  final DateTime departureDate;
  double rating;
  String? comment;

  CityEntry({
    required this.id,
    required this.userId,
    required this.name,
    required this.country,
    required this.arrivalDate,
    required this.departureDate,
    required this.rating,
    this.comment = ""
  });

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
    );
  }

  CityEntry copyWithId({int? id}) {
    return CityEntry(
        id: id ?? this.id,
        userId: userId,
        name: name,
        country: country,
        arrivalDate: arrivalDate,
        departureDate: departureDate,
        rating: rating);
  }
}