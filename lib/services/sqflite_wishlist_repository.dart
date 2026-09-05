import 'package:roamly/models/wishlist_entry_model.dart';
import 'package:roamly/services/wishlist_repository.dart';
import '../database/database_helper.dart';

class SqfliteWishlistRepository implements WishlistRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<WishlistEntry> addToWishlist(WishlistEntry entry) async{
    final db = await _dbHelper.database;
    final map = entry.toMap()..remove('id');
    final newId = await db.insert('wishlist_entries', map);
    return WishlistEntry(
      id: newId,
      userId: entry.userId,
      cityName: entry.cityName,
      country: entry.country,
      continent: entry.continent,
      latitude: entry.latitude,
      longitude: entry.longitude,
      createdAt: entry.createdAt,
    );
  }

  @override
  Future<List<WishlistEntry>> getWishlist(String userId) async{
    final db = await _dbHelper.database;
    final maps = await db.query(
      'wishlist_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => WishlistEntry.fromMap(map)).toList();
  }

  @override
  Future<void> removeFromWishlist(int id, String userId) async{
    final db = await _dbHelper.database;
    await db.delete(
      'wishlist_entries',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  @override
  Future<bool> isWishlisted(String userId, String cityName, double latitude, double longitude) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'wishlist_entries',
      where: 'userId = ? AND cityName = ? AND latitude = ? AND longitude = ?',
      whereArgs: [userId, cityName, latitude, longitude],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}