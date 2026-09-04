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
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE city_entries(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          userName TEXT NOT NULL,
          name TEXT NOT NULL,
          country TEXT NOT NULL,
          continent TEXT NOT NULL,
          arrivalDate TEXT NOT NULL,
          departureDate TEXT NOT NULL,
          rating REAL NOT NULL,
          comment TEXT,
          createdAt TEXT NOT NULL,
          latitude REAL,
          longitude REAL,
          imagePath TEXT
        )
        ''');
        
        await db.execute('''
        CREATE TABLE users(
          uid TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          username TEXT NOT NULL
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE city_entries ADD COLUMN latitude REAL');
          await db.execute('ALTER TABLE city_entries ADD COLUMN longitude REAL');
        }
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE users(  
            uid TEXT PRIMARY KEY,
            email TEXT NOT NULL,
            username TEXT NOT NULL
          )
          ''');
        }
        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE city_entries ADD COLUMN imagePath TEXT');
          } catch (e) {
            print("Database Upgrade: imagePath column might already exist: $e");
          }
        }
      },
    );
  }
}
