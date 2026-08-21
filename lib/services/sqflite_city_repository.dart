import 'package:roamly/database/database_helper.dart';
import 'package:roamly/models/city_entry_model.dart';
import 'package:roamly/services/city_repository.dart';

class SqfliteCityRepository implements CityRepository{
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<CityEntry>> getEntries(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'city_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => CityEntry.fromMap(m)).toList();
  }

  @override
  Future<CityEntry> addEntry(CityEntry entry) async {
    final db = await _dbHelper.database;
    final map = entry.toMap()..remove('id');
    final newId = await db.insert('city_entries', map);

    return entry.copyWith(id: newId);
  }

  @override
  Future<void> updateEntry(CityEntry entry) async {
    final db = await _dbHelper.database;
    await db.update(
        'city_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
    );
  }

  @override
  Future<void> deleteEntry(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'city_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}