import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:collection/collection.dart';
import 'package:flutter_application_1/main.dart';
import 'package:logger/logger.dart';

class SeeHistoryPage extends StatefulWidget {
  final dbHelper = DbHelper();
  SeeHistoryPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SeeHistoryPageState();
}

final _logger = Logger();

class _SeeHistoryPageState extends State<SeeHistoryPage> {
  List<GameChecklist> gameChecklists = [];
  Map<int, List<Match>> matches = {};

  Future<void> reloadGameChecklist() async {
    gameChecklists = await widget.dbHelper.getGameChecklists();
    for (var game in gameChecklists) {
      _logger.d("game: ${game.name}, id: ${game.id}");
    }
  }

  Future<void> reloadMatch() async {
    final matchesInDb = await widget.dbHelper.getMatch();
    matches = matchesInDb
        .groupListsBy((e) => e.gameChecklistId)
        .map((key, value) => MapEntry(key, value));
    for (var key in matches.keys) {
      _logger.d("key: $key");
      for (var match in matches[key]!) {
        _logger.d("match: ${match.matchChecklistItems.length}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      await reloadGameChecklist();
      await reloadMatch();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: gameChecklists.length,
        child: Scaffold(
            appBar: _myMenuBar(context, gameChecklists),
            body: TabBarView(
                children: gameChecklists
                    .map((game) => _myViewOfTab(matches[game.id] ?? []))
                    .toList())));
  }
}

PreferredSizeWidget _myMenuBar(
    BuildContext context, List<GameChecklist> gameChecklists) {
  return AppBar(
      title: const Text('試合履歴', style: TextStyle(fontSize: 30)),
      bottom: TabBar(
        tabAlignment: TabAlignment.center,
        isScrollable: true,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        tabs: gameChecklists.map((game) => Tab(text: game.name)).toList(),
      ));
}

Widget _myViewOfTab(List<Match> matches) {
  if (matches.isEmpty) {
    return const Text("このゲームの試合履歴はまだありません", style: TextStyle(fontSize: 20));
  } else {
    return Column(
        children: matches
            .sortedBy((element) => element.createdAt)
            .map((e) => generateMatchCard(e))
            .toList());
  }
}

Card generateMatchCard(Match match) {
  logger.d("match card generating");
  match.matchChecklistItems.map((e) => logger.d(e.title));

  return Card(
    child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(match.createdAt.toString()),
            ...match.matchChecklistItems
                .map((e) => _matchCheckItemView(e.title, e.isChecked)),
          ],
        )),
  );
}

Widget _matchCheckItemView(String title, bool isChecked) {
  final icon = isChecked
      ? const Icon(Icons.check_box, color: Colors.green)
      : const Icon(Icons.check_box_outline_blank, color: Colors.grey);
  return ListTile(
      leading: icon,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 18.0),
      ));
}
