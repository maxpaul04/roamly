import 'package:roamly/models/city_entry_model.dart';

class MockedDataCityRepository {

  final List<CityEntry> _mockCityData = [
    CityEntry(
      id: 1,
      name: 'Paris',
      country: 'France',
      rating: 4.5,
      comment: 'The pastries were incredible, but the Louvre was packed.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 50)),
      departureDate: DateTime.now().subtract(const Duration(days: 30)), userId: '1',
  createdAt: DateTime.now(),

  ),
    CityEntry(
      id: 2,
      name: 'Vienna',
      country: 'Austria',
      rating: 4.0,
      arrivalDate: DateTime.now().subtract(const Duration(days: 45)),
      departureDate: DateTime.now().subtract(const Duration(days: 40)), userId: '2',
      createdAt: DateTime.now(),

    ),
    CityEntry(
      id: 3,
      name: 'London',
      country: 'UK',
      rating: 3.5,
      comment: 'It rained. Then it stopped. Then it rained again just to make sure I was still wet. The pubs are the only dry place left.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 35)),
      departureDate: DateTime.now().subtract(const Duration(days: 30)),
      userId: '3',
      createdAt: DateTime.now(),

    ),
    CityEntry(
      id: 4,
      name: 'Berlin',
      country: 'Germany',
      rating: 4.5,
      comment: 'Tried to get into Berghain. The doorman looked at my shoes and basically told my soul to go home. 5 stars for the techno I heard from the sidewalk.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 25)),
      departureDate: DateTime.now().subtract(const Duration(days: 20)),
      userId: '4',
      createdAt: DateTime.now(),

    ),
    CityEntry(
      id: 5,
      name: 'Rome',
      country: 'Italy',
      rating: 5.0,
      comment: 'I am 80% pasta now. If I stay another day, I will legally become a noodle. The Colosseum is okay I guess.',
      arrivalDate: DateTime.now().subtract(const Duration(days: 15)),
      departureDate: DateTime.now().subtract(const Duration(days: 10)),
      userId: '5',
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<CityEntry>> getAllCityEntries() async {
    return _mockCityData;
  }
}