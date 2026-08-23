import 'package:roamly/models/city_entry_model.dart';

abstract class CityRepository {
  Future<List<CityEntry>> getEntries(String userId);
  Future<List<CityEntry>> getAllEntries(); // New: Get everything for the Feed
  Future<CityEntry> addEntry(CityEntry entry);
  Future<void> updateEntry(CityEntry entry);
  Future<void> deleteEntry(int id, String userId);
}
