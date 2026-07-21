class CityEntry {
  final int id;
  final String name;
  final String country;
  final DateTime arrivalDate;
  final DateTime departureDate;
  double rating;
  String? comment;

  CityEntry({
    required this.id,
    required this.name,
    required this.country,
    required this.arrivalDate,
    required this.departureDate,
    required this.rating,
    this.comment = ""
  });
}