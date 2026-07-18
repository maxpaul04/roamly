class CityEntry {
  final int id;
  final String name;
  final String country;
  final DateTime arrivalDate;
  final DateTime departureDate;
  double rating; //from 1 to 5 stars, with half stars possible
  String comment;

  CityEntry({
    required this.id,
    required this.name,
    required this.country,
    required this.arrivalDate,
    required this.departureDate,
    required this.rating,
    required this.comment,
  });
}