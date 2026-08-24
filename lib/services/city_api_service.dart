//Note: the hardcoded API-key is a deliberate trade-off to keep the app functioning easier.
// In real production code, I would never hardcode API keys in this way.
//This is a free tier, so the worst "damage" would be using up my daily rate limits, no financial/data losses
import 'dart:convert';

import 'package:http/http.dart' as http;

const String apiKey = 'bcc53fbab9msh155d18ede319392p17bff6jsn992353ef1b63';
const String _geoDbUrl = 'wft-geo-db.p.rapidapi.com';

class CitySearchResult {
  final String name;
  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;

  CitySearchResult({
    required this.name,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  factory CitySearchResult.fromJson(Map<String, dynamic> json) {
    return CitySearchResult(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['countryCode'] ?? '',
      latitude: (json['latitude']! as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CityApiService {
  static const String _baseUrl = 'https://$_geoDbUrl/v1/geo/places';

  Future<List<CitySearchResult>> searchCities(String query) async {
    //only query the cities with an input over 2 letters, rather than exhausting my API limits
    if (query.trim().length < 2) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'namePrefix': query,
      'limit': '10',
      'sort': '-population',
      'type': 'CITY',
    });

    final response = await http.get(uri, headers: {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': _geoDbUrl,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to load cities: ${response.statusCode} ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['data'] as List<dynamic>;

    return results
        .map((item) => CitySearchResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
