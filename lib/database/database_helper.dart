import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'roamly.db');
    return openDatabase(
        path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE city_entries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          name TEXT NOT NULL,
          country TEXT NOT NULL,
          arrivalDate TEXT NOT NULL,
          departureDate TEXT NOT NULL,
          rating REAL NOT NULL,
          comment TEXT,
          createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }
}