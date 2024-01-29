import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/add_game_checklist_item_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/add_game_checklist_page.dart';
import 'package:logger/logger.dart';

final logger = Logger();

const double toolbarHeight = 100.0;

class CheckboxListTileState {
  bool checkboxValue = false;
  String title = "";
  String subtitle = "";

  CheckboxListTileState(this.checkboxValue, this.title, this.subtitle);
}

class ChecklistPage extends StatefulWidget {
  final DbHelper dbHelper = DbHelper();
  ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  List<GameChecklist> gameChecklists = [];
  List<CheckboxListTileState> checkboxListTileStateList = [];

  Future<void> reloadGameChecklistItem() async {
    final checklistItems = await widget.dbHelper.getGameChecklistItems();
    checkboxListTileStateList = checklistItems
        .map((e) => CheckboxListTileState(false, e.title, e.subtitle))
        .toList();
  }

  Future<void> reloadGameChecklist() async {
    gameChecklists = await widget.dbHelper.getGameChecklists();
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      await reloadGameChecklist();
      await reloadGameChecklistItem();
      setState(() {});
    });
  }

  SpeedDial myFloatingActionButton(BuildContext context) {
    return SpeedDial(
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.create),
            backgroundColor: Colors.blue,
            label: "ゲームを追加する",
            onTap: () async {
              final gameTitleToAdd = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddGameChecklistPage()),
              );

              await widget.dbHelper
                  .insertGameChecklist(GameChecklist(0, gameTitleToAdd));
              final a = await widget.dbHelper.getGameChecklists();
              logger.d(a);

              await reloadGameChecklist();

              setState(() => ());
            },
            labelStyle: const TextStyle(fontWeight: FontWeight.w500)),
      ],
      activeIcon: Icons.close,
      child: const Icon(Icons.add),
    );
  }

  PreferredSizeWidget _myMenuBar(List<GameChecklist> gameChecklists) {
    return AppBar(
      title: const Center(child: Text('練習メニュー')),
      bottom: TabBar(
        tabs: gameChecklists.map((e) => Tab(text: e.name)).toList(),
      ),
    );
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
        (String, String) result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddChecklistItemPage()),
        );

        if (result.$1.isNotEmpty) {
          await widget.dbHelper.insertGameChecklistItem(
              ChecklistItem(0, 0 /*デバッグ用に適当な値を入れています*/, result.$1, result.$2));
        }
        await reloadGameChecklistItem();
        setState(() => ());
      },
      child: const Text('click here'),
    ));
    return DefaultTabController(
        length: gameChecklists.length, //タブの数
        child: Scaffold(
            appBar: _myMenuBar(gameChecklists),
            body: TabBarView(
                children: gameChecklists
                    .map((_) => Column(children: checkboxListTileWidgets))
                    .toList()),
            floatingActionButton: myFloatingActionButton(context)));
  }
}
