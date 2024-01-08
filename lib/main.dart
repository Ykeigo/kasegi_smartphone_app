import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
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
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: CheckboxListTileExample(key: super.key, dbHelper: DbHelper()),
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
  List<CheckboxListTileState> checkboxListTileStateList = [
    CheckboxListTileState(false, "Headline", "Supporting text"),
    CheckboxListTileState(false, "ヘッドライン", "サポーティングテキスト"),
    CheckboxListTileState(false, "Headline",
        "Longer supporting text to demonstrate how the text wraps and the checkbox is centered vertically with the text."),
    CheckboxListTileState(false, "Headline",
        "Longer supporting text to demonstrate how the text wraps and how setting 'CheckboxListTile.isThreeLine = true' aligns the checkbox to the top vertically with the text."),
  ];

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
        await widget.dbHelper
            .insertChecklistItem(ChecklistItem("title", "subtitle"));
        final checklistItems = await widget.dbHelper.getChecklistItems();
        checkboxListTileStateList.addAll(checklistItems
            .map((e) => CheckboxListTileState(false, e.title, e.subtitle)));

        for (var element in checkboxListTileStateList) {
          logger.d(element.title);
        }
        setState(() => ());
      },
      child: const Text('click here'),
    ));
    return Scaffold(
        appBar: AppBar(title: const Text('CheckboxListTile Sample')),
        body: Column(children: checkboxListTileWidgets));
  }
}
