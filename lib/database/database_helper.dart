import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/mood_log_models.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'moodlog.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood TEXT NOT NULL,
        intensityLevel INTEGER NOT NULL,
        moodFactors TEXT NOT NULL,
        location TEXT NOT NULL,
        notes TEXT,
        selectedTime TEXT NOT NULL,
        selectedDate TEXT NOT NULL
      )
    ''');
  }

  // ✅ Insert MoodLog
  Future<int> insertMoodLog(MoodLog moodLog) async {
    final db = await database;
    int result = await db.insert(
      'moods',
      moodLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Inserted Mood Log: ${moodLog.toString()}"); // ✅ Debugging print statement
    return result;
  }

  // ✅ Fetch Mood Logs by Date
  Future<List<MoodLog>> getMoodsByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      where: "selectedDate = ?",
      whereArgs: [date], // ✅ Compare only date part
    );

    return List.generate(maps.length, (i) {
      return MoodLog(
        mood: maps[i]['mood'],
        intensityLevel: maps[i]['intensityLevel'],
        moodFactors: (maps[i]['moodFactors'] as String).split(','), // ✅ Convert back to List
        location: maps[i]['location'],
        notes: maps[i]['notes'],
        selectedTime: maps[i]['selectedTime'],
        selectedDate: DateTime.parse(maps[i]['selectedDate']), // ✅ Convert back to DateTime
      );
    });
  }



  // ✅ Check if a mood is logged for a specific date & time
  Future<bool> isMoodLogged(String date, String time) async {
    final db = await database;
    final result = await db.query(
      'moods',
      where: 'selectedDate = ? AND selectedTime = ?',
      whereArgs: [date, time],
    );
    return result.isNotEmpty;
  }

  // ✅ Delete Mood by ID
  Future<int> deleteMood(int id) async {
    final db = await database;
    return await db.delete('moods', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MoodLog>> getMoodsInRange(String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      where: "selectedDate BETWEEN ? AND ?",
      whereArgs: [startDate, endDate], // ✅ Ensure the dates are formatted as strings
    );

    return List.generate(maps.length, (i) {
      return MoodLog.fromMap(maps[i]); // ✅ Convert map to MoodLog object
    });
  }


  Future<List<MoodLog>> getAllMoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('moods'); // ✅ No WHERE clause to fetch everything
    print("length"+ (maps.length).toString());
    return List.generate(maps.length, (i) {
      return MoodLog.fromMap(maps[i]);
    });
  }

  // ✅ Delete all mood logs (Empty the table but keep the structure)
  Future<void> deleteAllMoods() async {
    final db = await database;
    await db.delete('moods'); // ✅ Deletes all rows in the moods table
    print("✅ All mood logs deleted successfully.");
  }

}
