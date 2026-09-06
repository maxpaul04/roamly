class Stats {
  final int totalTrips;
  final int distinctCities;
  final int distinctCountries;
  final int distinctContinents;
  final double averageRating;
  final double averageTripDuration;
  final int totalDaysTravelled;

  const Stats({
    required this.totalTrips,
    required this.distinctCities,
    required this.distinctCountries,
    required this.distinctContinents,
    required this.averageRating,
    required this.averageTripDuration,
    required this.totalDaysTravelled,
  });

  static const emptyStats = Stats(
    totalTrips: 0,
    distinctCities: 0,
    distinctCountries: 0,
    distinctContinents: 0,
    averageRating: 0.0,
    averageTripDuration: 0.0,
    totalDaysTravelled: 0,
  );
}