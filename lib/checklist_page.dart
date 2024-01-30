import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/add_game_checklist_item_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/add_game_checklist_page.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';

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
  Map<int, List<CheckboxListTileState>> checkboxListTileStateList = {};

  Future<void> reloadGameChecklistItem() async {
    final checklistItems = await widget.dbHelper.getGameChecklistItems();
    checkboxListTileStateList = checklistItems
        .groupListsBy((e) => e.gameChecklistId)
        .map((key, checkItems) => MapEntry(
            key,
            checkItems
                .map((item) =>
                    CheckboxListTileState(false, item.title, item.subtitle))
                .toList()));
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
        title: Text('練習メニュー'),
        bottom: TabBar(
          tabAlignment: TabAlignment.center,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          tabs: gameChecklists.map((e) => Tab(text: e.name)).toList(),
        ));
  }

  Widget _myCheckItemsWidget(int gameChecklistId) {
    final checkitemAndStates = checkboxListTileStateList[gameChecklistId];
    List<Widget> checkboxListTileWidgets;
    if (checkitemAndStates == null) {
      checkboxListTileWidgets = [const Text("Loading...")];
    } else {
      checkboxListTileWidgets = checkitemAndStates
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
    }
    checkboxListTileWidgets.add(ElevatedButton(
      onPressed: () async {
        (String, String) result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddChecklistItemPage()),
        );

        if (result.$1.isNotEmpty) {
          await widget.dbHelper.insertGameChecklistItem(ChecklistItem(
              0 /*ignored*/, gameChecklistId, result.$1, result.$2));
        }
        await reloadGameChecklistItem();
        setState(() => ());
      },
      child: const Text('チェック項目を追加'),
    ));
    return Column(children: checkboxListTileWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: gameChecklists.length, //タブの数
        child: Scaffold(
            appBar: _myMenuBar(gameChecklists),
            body: Stack(alignment: Alignment.topCenter, children: <Widget>[
              TabBarView(
                  children: gameChecklists
                      .map((gameChecklist) =>
                          _myCheckItemsWidget(gameChecklist.id))
                      .toList()),
              Positioned(
                bottom: 10.0,
                width: 110.0,
                height: 110.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    //foregroundColor: Colors.black,
                    shape: const CircleBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: const Text('開始！',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  onPressed: () {},
                ),
              ),
            ]),
            floatingActionButton: myFloatingActionButton(context)));
  }
}
