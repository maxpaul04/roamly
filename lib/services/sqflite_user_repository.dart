import 'package:sqflite/sqflite.dart';
import 'package:roamly/database/database_helper.dart';
import 'package:roamly/models/user_model.dart';
import 'package:roamly/services/user_repository.dart';

class SqfliteUserRepository implements UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> saveUser(UserModel user) async {
    final db = await _dbHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  @override
  Future<void> deleteUser(String uid) async {
    final db = await _dbHelper.database;
    await db.delete(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  @override
  Future<bool> isUsernameTaken(String username) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [username.toLowerCase()],
    );
    return maps.isNotEmpty;
  }
}
