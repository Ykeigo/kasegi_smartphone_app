import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_application_1/checklist_page.dart';

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
      theme: ThemeData(useMaterial3: true, fontFamily: "MPLUS_Rounded_1c"),
      home: SafeArea(child: ChecklistPage(key: super.key)),
    );
  }
}
