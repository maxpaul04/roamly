import 'dart:convert';
import 'package:flutter/services.dart';

class ContinentMapper {
  static Map<String, String>? _countryToContinent;

  static Future<void> loadMapping() async {
    if (_countryToContinent != null) return;

    final String response = await rootBundle.loadString('lib/utils/country-by-continent.json');
    final List<dynamic> data = json.decode(response);
    
    _countryToContinent = {
      for (var item in data) item['country'].toString(): item['continent'].toString()
    };
  }

  static String getContinent(String countryName) {
    return _countryToContinent?[countryName] ?? 'Unknown';
  }
}
