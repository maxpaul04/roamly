import '../models/stats.dart';
import 'city_repository.dart';

//calculates users lifetime stats based on their city entries
class StatsService {
  final CityRepository cityRepository;

  StatsService({required this.cityRepository});

  Future<Stats> calculateStatsFor(String uid) async {
    final entries = await cityRepository.getEntries(uid);

    if (entries.isEmpty) {
      return Stats.emptyStats;
    }

    final int totalTrips = entries.length;

    //distinct cities counted by name and country
    final distinctCities = entries.map((e) => '${e.name.toLowerCase()}, ${e.country.toLowerCase()}').toSet().length;
    final distinctCountries = entries.map((e) => e.country.toLowerCase()).toSet().length;
    final distinctContinents = entries.map((e) => e.continent.toLowerCase()).toSet().length;

    final averageRating = entries.map((e) => e.rating).reduce((a, b) => a + b) / totalTrips;

    final totalDaysTravelled = entries.fold<int>(0, (sum, entry) {
      final days = entry.departureDate.difference(entry.arrivalDate).inDays + 1;
      return sum + days;
    });

    final averageTripDuration = totalDaysTravelled / totalTrips;

    final citiesThisYear = entries.where((e) => e.arrivalDate.year == DateTime.now().year).length;

    final countryCount = <String, int>{};
    for (final e in entries) {
      countryCount[e.country] = (countryCount[e.country] ?? 0) + 1;
    }
    final topCountry = countryCount.entries.
      reduce((a, b) => a.value > b.value ? a : b)
      .key;


    return Stats(
      totalTrips: totalTrips,
      distinctCities: distinctCities,
      distinctCountries: distinctCountries,
      distinctContinents: distinctContinents,
      averageRating: averageRating,
      averageTripDuration: averageTripDuration,
      totalDaysTravelled: totalDaysTravelled,
      citiesThisYear: citiesThisYear,
      topCountry: topCountry,
    );
  }
}