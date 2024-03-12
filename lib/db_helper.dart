import 'package:game_instinct/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChecklistItem {
  int id = 0;
  String title = "";
  String subtitle = "";
  int gameChecklistId = 0;

  ChecklistItem(this.id, this.gameChecklistId, this.title, this.subtitle);
}

class GameChecklist {
  int id = 0;
  String name = "";

  GameChecklist(this.id, this.name);
}

class MatchChecklistItem {
  int id = 0;
  String title = "";
  String subtitle = "";
  int matchId = 0;
  bool isChecked = false;

  MatchChecklistItem(
      this.id, this.matchId, this.title, this.subtitle, this.isChecked);
}

class Match {
  int id = 0;
  int gameChecklistId = 0;
  String createdAt = "";
  List<MatchChecklistItem> matchChecklistItems = [];

  Match(
      this.id, this.gameChecklistId, this.createdAt, this.matchChecklistItems);
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
    //await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        logger.d("Connection to yanagy's local DB created");
        //作成
        await db.execute('''
          CREATE TABLE IF NOT EXISTS game_checklists (
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
        await db.execute('''
          CREATE TABLE IF NOT EXISTS matches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            game_checklist_id INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
          ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS match_checklist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            match_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            is_checked TEXT NOT NULL
          )
          ''');
      },
    );
  }

  ///渡されたChecklistItemをinsertします。idは無視されます。
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
        maps[i]['id'],
        maps[i]['game_checklist_id'],
        maps[i]['title'],
        maps[i]['subtitle'],
      );
    });
  }

  ///渡されたGameChecklistをinsertします。idは無視されます。
  Future<void> insertGameChecklist(GameChecklist gameChecklist) async {
    final db = await database;
    await db.insert(
      'game_checklists',
      {
        "name": gameChecklist.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GameChecklist>> getGameChecklists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM game_checklists'); //.query('checklist_items');
    return List.generate(maps.length, (i) {
      return GameChecklist(
        maps[i]['id'],
        maps[i]['name'],
      );
    });
  }

  ///渡されたMatchをinsertします。idとcreatedAtは無視されます。
  Future<void> insertMatch(Match match) async {
    final db = await database;
    final id = await db.insert(
      'matches',
      {
        "game_checklist_id": match.gameChecklistId,
        "created_at": DateTime.now().toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (var item in match.matchChecklistItems) {
      await db.insert(
        'match_checklist_items',
        {
          "match_id": id,
          "title": item.title,
          "subtitle": item.subtitle,
          "is_checked": item.isChecked.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Match>> getMatch() async {
    final db = await database;
    final List<Map<String, dynamic>> matchMaps =
        await db.rawQuery('SELECT * FROM matches');
    final List<Map<String, dynamic>> matchChecklistMaps =
        await db.rawQuery('SELECT * FROM match_checklist_items');

    return List.generate(matchMaps.length, (i) {
      return Match(
          matchMaps[i]['id'],
          matchMaps[i]['game_checklist_id'],
          matchMaps[i]['created_at'],
          matchChecklistMaps
              .where((element) => element['match_id'] == matchMaps[i]['id'])
              .map((e) => MatchChecklistItem(e['id'], e['match_id'], e['title'],
                  e['subtitle'], e['is_checked'] == "true"))
              .toList());
    });
  }
}
