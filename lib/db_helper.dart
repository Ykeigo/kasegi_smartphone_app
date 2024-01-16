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
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        //存在確認
        final List<Map<String, dynamic>> tables =
            await db.rawQuery("SHOW TABLES LIKE 'checklist_items'");
        if (tables.isEmpty) {
          //作成
          await db.execute('''
          CREATE TABLE IF NOT EXISTS checklist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL
          )
          ''');
        }
      },
    );
  }

  Future<void> insertChecklistItem(ChecklistItem checklistItem) async {
    final db = await database;
    await db.insert(
      'checklist_items',
      {"title": checklistItem.title, "subtitle": checklistItem.subtitle},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
