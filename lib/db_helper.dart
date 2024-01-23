import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChecklistItem {
  String title = "";
  String subtitle = "";
  int gameChecklistId = 0;

  ChecklistItem(this.gameChecklistId, this.title, this.subtitle);
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
        //全部消す（デバッグ用）
        await db.execute("DROP TABLE IF EXISTS game_checklist");
        await db.execute("DROP TABLE IF EXISTS checklist_items");

        //作成
        await db.execute('''
          CREATE TABLE IF NOT EXISTS game_checklist (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
          ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS game_checklist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            game_checklist_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL
          )
          ''');
      },
    );
  }

  Future<void> insertGameChecklistItem(ChecklistItem checklistItem) async {
    final db = await database;
    await db.insert(
      'game_checklist_items',
      {
        "game_checklist_id": checklistItem.gameChecklistId,
        "title": checklistItem.title,
        "subtitle": checklistItem.subtitle
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChecklistItem>> getGameChecklistItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM game_checklist_items'); //.query('checklist_items');
    return List.generate(maps.length, (i) {
      return ChecklistItem(
        maps[i]['game_checklist_id'],
        maps[i]['title'],
        maps[i]['subtitle'],
      );
    });
  }
}
