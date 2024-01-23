import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/add_game_checklist_item_page.dart';
import 'package:flutter_application_1/add_game_checklist_page.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_application_1/db_helper.dart';

/// Flutter code sample for [CheckboxListTile].

const Duration timeLimit = Duration(seconds: 5);

final logger = Logger();

void main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'kasegi_database.db'),
  ).timeout(timeLimit,
      onTimeout: () => throw TimeoutException(
          "Failed to open database. Timeout after $timeLimit"));

  database.then((database) {
    logger.d("Connection to yanagy's local DB established");
    runApp(const CheckboxListTileApp());
  }, onError: (error, stackTrace) => logger.d(error));
}

class CheckboxListTileApp extends StatelessWidget {
  const CheckboxListTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: SafeArea(
          child: CheckboxListTileExample(key: super.key, dbHelper: DbHelper())),
    );
  }
}

class CheckboxListTileExample extends StatefulWidget {
  final DbHelper dbHelper;
  const CheckboxListTileExample({super.key, required this.dbHelper});

  @override
  State<CheckboxListTileExample> createState() =>
      _CheckboxListTileExampleState();
}

class CheckboxListTileState {
  bool checkboxValue = false;
  String title = "";
  String subtitle = "";

  CheckboxListTileState(this.checkboxValue, this.title, this.subtitle);
}

class _CheckboxListTileExampleState extends State<CheckboxListTileExample> {
  List<CheckboxListTileState> checkboxListTileStateList = [];

  Future<void> reloadGameCheckItem() async {
    final checklistItems = await widget.dbHelper.getGameChecklistItems();
    checkboxListTileStateList = checklistItems
        .map((e) => CheckboxListTileState(false, e.title, e.subtitle))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      await reloadGameCheckItem();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> checkboxListTileWidgets = checkboxListTileStateList
        .map((e) => List<Widget>.from([
              CheckboxListTile(
                value: e.checkboxValue,
                onChanged: (bool? value) {
                  setState(() {
                    e.checkboxValue = value!;
                  });
                },
                title: Text(e.title),
                subtitle: Text(e.subtitle),
              ),
              const Divider(height: 0)
            ]))
        .expand((element) => element)
        .toList();

    checkboxListTileWidgets.add(ElevatedButton(
      onPressed: () async {
        logger.d(context);
        (String, String) result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddChecklistItemPage()),
        );
        logger.d("result: $result");

        if (result.$1.isNotEmpty) {
          await widget.dbHelper.insertGameChecklistItem(
              ChecklistItem(0 /*デバッグ用に適当な値を入れています*/, result.$1, result.$2));
        }
        await reloadGameCheckItem();
        setState(() => ());
      },
      child: const Text('click here'),
    ));
    return Scaffold(
        body: Column(children: [
      const MyMenuBar(),
      Column(children: checkboxListTileWidgets)
    ]));
  }
}

class MyMenuBar extends StatefulWidget {
  const MyMenuBar({super.key});

  @override
  State<MyMenuBar> createState() => _MyMenuBarState();
}

class _MyMenuBarState extends State<MyMenuBar> {
  Widget addGameChecklistButton(BuildContext context) {
    logger.d(context);
    return MenuItemButton(
      onPressed: () async {
        logger.d(context);
        logger.d(Navigator);
        (String, String) result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddGameChecklistPage()),
        );
        logger.d("result: $result");
      },
      child: const Text("練習メニューを作成"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: MenuBar(
                children: <Widget>[
                  SubmenuButton(
                    menuChildren: <Widget>[addGameChecklistButton(context)],
                    child: const Icon(Icons.menu),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
