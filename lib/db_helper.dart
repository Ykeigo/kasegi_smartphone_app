import 'package:flutter_application_1/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChecklistItem {
  String title = "";
  String subtitle = "";

  ChecklistItem(this.title, this.subtitle);
}

class DbHelper {
  DbHelper() {
    initDB();
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'kasegi_database.db');
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS checklist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertChecklistItem(ChecklistItem checklistItem) async {
    final db = await database;
    final saved = await db.insert(
      'checklist_items',
      {"title": checklistItem.title, "subtitle": checklistItem.subtitle},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    //logger.d("Inserted ${checklistItem.title} into DB, id: $saved");
  }

  Future<List<ChecklistItem>> getChecklistItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM checklist_items'); //.query('checklist_items');
    return List.generate(maps.length, (i) {
      return ChecklistItem(
        maps[i]['title'],
        maps[i]['subtitle'],
      );
    });
  }
}
