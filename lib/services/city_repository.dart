import 'package:roamly/models/city_entry_model.dart';

class CityRepository {

  final List<CityEntry> _mockCityData = [
    CityEntry(
      id: 1,
      name: 'Paris',
      country: 'France',
      rating: 4.5,
      comment: 'The pastries were incredible, but the Louvre was packed.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 50)),
      departureDate: DateTime.now().subtract(const Duration(days: 30))
    ),
    CityEntry(
      id: 2,
      name: 'Vienna',
      country: 'Austria',
      rating: 4.0,
      arrivalDate: DateTime.now().subtract(const Duration(days: 45)),
      departureDate: DateTime.now().subtract(const Duration(days: 40)),
    ),
    CityEntry(
      id: 3,
      name: 'London',
      country: 'UK',
      rating: 3.5,
      comment: 'It rained. Then it stopped. Then it rained again just to make sure I was still wet. The pubs are the only dry place left.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 35)),
      departureDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CityEntry(
      id: 4,
      name: 'Berlin',
      country: 'Germany',
      rating: 4.5,
      comment: 'Tried to get into Berghain. The doorman looked at my shoes and basically told my soul to go home. 5 stars for the techno I heard from the sidewalk.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 25)),
      departureDate: DateTime.now().subtract(const Duration(days: 20)),
    ),
    CityEntry(
      id: 5,
      name: 'Rome',
      country: 'Italy',
      rating: 5.0,
      comment: 'I am 80% pasta now. If I stay another day, I will legally become a noodle. The Colosseum is okay I guess.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 15)),
      departureDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
    CityEntry(
      id: 6,
      name: 'Amsterdam',
      country: 'Netherlands',
      rating: 4.0,
      comment: 'Almost got run over by 14 bicycles, three trams, and a very aggressive duck. Beautiful canals though.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 8)),
      departureDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CityEntry(
      id: 7,
      name: 'New York',
      country: 'USA',
      rating: 4.0,
      comment: 'Paid 18 dollars for a sandwich. The sandwich didn\'t even say thank you. The energy is great, my bank account is sad.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 4)),
      departureDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CityEntry(
      id: 8,
      name: 'Tokyo',
      country: 'Japan',
      rating: 5.0,
      comment: 'The vending machine sold me hot coffee, a clean shirt, and a life lesson. I never want to leave.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 200)),
      departureDate: DateTime.now().subtract(const Duration(days: 190)),
    ),
    CityEntry(
      id: 9,
      name: 'Reykjavik',
      country: 'Iceland',
      rating: 4.5,
      comment: 'It is so beautiful it looks fake. Also, I am currently bankrupt because I bought a soup.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 120)),
      departureDate: DateTime.now().subtract(const Duration(days: 115)),
    ),
    CityEntry(
      id: 10,
      name: 'Bangkok',
      country: 'Thailand',
      rating: 4.8,
      comment: 'I took a Tuk-Tuk and I think I met God. Fastest 2 miles of my life. The street food is worth the adrenaline rush.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 60)),
      departureDate: DateTime.now().subtract(const Duration(days: 55)),
    ),
  ];

  Future<List<CityEntry>> getAllCityEntries() async {
    return _mockCityData;
  }
}