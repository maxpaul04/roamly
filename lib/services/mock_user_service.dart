import 'package:roamly/services/user_repository.dart';

import '../models/city_entry_model.dart';
import '../models/user_model.dart';
import 'city_repository.dart';

//create mocked users to test out UI without having to manually add users
class MockUserService {
  final UserRepository userRepository;
  final CityRepository cityRepository;

  MockUserService({
    required this.userRepository,
    required this.cityRepository,
  });

  static const _demoUsers = [
    (uid: 'seed_demo_1', email: 'demo1@roamly.local', username: 'travel_lena'),
    (uid: 'seed_demo_2', email: 'demo2@roamly.local', username: 'nomad_finn'),
  ];

  Future<void> seedIfNeeded() async {
    for (final demo in _demoUsers) {
      final existing = await userRepository.getUser(demo.uid);
      if (existing != null) continue; // if already seeded, skip
      await _seedOneUser(demo.uid, demo.email, demo.username);
    }
  }

  Future<void> _seedOneUser(String uid, String email, String username) async {
    await userRepository.saveUser(UserModel(uid: uid, email: email, userName: username,));

    final entries = uid == 'seed_demo_1' ? _sampleEntriesFor1(uid, username) : _sampleEntriesFor2(uid, username);
    for (final entry in entries) {
      await cityRepository.addEntry(entry);
    }
  }

  List<CityEntry> _sampleEntriesFor1(String uid, String userName) {
    return [
      CityEntry(
        id: CityEntry.UNSAVED_ID,
        userId: uid,
        userName: userName,
        name: 'Lisbon',
        country: 'Portugal',
        continent: 'Europe',
        arrivalDate: DateTime(2024, 5, 10),
        departureDate: DateTime(2024, 5, 17),
        rating: 4.5,
        comment: 'Great food, steep hills.',
        createdAt: DateTime(2024, 5, 18),
        latitude: 38.7223,
        longitude: -9.1393,
        imagePath: null,
      ),
      CityEntry(
        id: CityEntry.UNSAVED_ID,
        userId: uid,
        userName: userName,
        name: 'Kyoto',
        country: 'Japan',
        continent: 'Asia',
        arrivalDate: DateTime(2023, 11, 2),
        departureDate: DateTime(2023, 11, 9),
        rating: 5.0,
        comment: 'Temples everywhere, worth the trip.',
        createdAt: DateTime(2023, 11, 10),
        latitude: 35.0116,
        longitude: 135.7681,
        imagePath: null,
      ),
    ];
  }

  List<CityEntry> _sampleEntriesFor2(String uid, String userName) {
    return [
      CityEntry(
        id: CityEntry.UNSAVED_ID,
        userId: uid,
        userName: userName,
        name: 'Venice',
        country: 'Italy',
        continent: 'Europe',
        arrivalDate: DateTime(2023, 8, 3),
        departureDate: DateTime(2023, 8, 6),
        rating: 3.5,
        comment: 'Beautiful city, but my GPS gave up after 10 minutes and just started displaying a shrug emoji. Got lost twice, proposed to a gondola out of sheer Stockholm syndrome.',
        createdAt: DateTime(2023, 8, 7),
        latitude: 45.4408,
        longitude: 12.3155,
        imagePath: null,
      ),
      CityEntry(
        id: CityEntry.UNSAVED_ID,
        userId: uid,
        userName: userName,
        name: 'Reykjavik',
        country: 'Iceland',
        continent: 'Europe',
        arrivalDate: DateTime(2024, 2, 14),
        departureDate: DateTime(2024, 2, 19),
        rating: 4.0,
        comment: 'Tried to see the Northern Lights. Saw a cloud. A very committed, very opaque cloud. 10/10 hot dogs though.',
        createdAt: DateTime(2024, 2, 20),
        latitude: 64.1466,
        longitude: -21.9426,
        imagePath: null,
      ),
      CityEntry(
        id: CityEntry.UNSAVED_ID,
        userId: uid,
        userName: userName,
        name: 'Bangkok',
        country: 'Thailand',
        continent: 'Asia',
        arrivalDate: DateTime(2022, 12, 1),
        departureDate: DateTime(2022, 12, 10),
        rating: 4.5,
        comment: 'Ordered "not spicy." The waiter looked at me with pity. He was right to. Also a monkey stole my sunglasses and honestly he looked better in them.',
        createdAt: DateTime(2022, 12, 11),
        latitude: 13.7563,
        longitude: 100.5018,
        imagePath: null,
      ),
    ];
  }
}
