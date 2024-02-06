import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/add_game_checklist_item_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/add_game_checklist_page.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';

final logger = Logger();

enum InGameStatus { preGame, inGame, postGame }

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

void openSnackbar() {
  Get.snackbar(
    '記録しました！',
    '',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.black,
    colorText: Colors.white,
    borderRadius: 0,
    margin: const EdgeInsets.all(0),
  );
}

class _ChecklistPageState extends State<ChecklistPage> {
  InGameStatus inGameStatus = InGameStatus.preGame;
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

  Widget _myCheckItemsWidget(int gameChecklistId, bool enableCheckbox) {
    final checkitemAndStates = checkboxListTileStateList[gameChecklistId];
    List<Widget> checkboxListTileWidgets;
    if (checkitemAndStates == null) {
      checkboxListTileWidgets = [const Text("チェック項目を追加しましょう！")];
    } else {
      checkboxListTileWidgets = checkitemAndStates
          .map((e) => List<Widget>.from([
                CheckboxListTile(
                  value: e.checkboxValue,
                  onChanged: enableCheckbox
                      ? (bool? value) {
                          setState(() {
                            e.checkboxValue = value!;
                          });
                        }
                      : null,
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

  Widget gameStartusChangeButton() {
    String buttonText = '';
    if (inGameStatus == InGameStatus.preGame) {
      buttonText = '開始！';
    } else if (inGameStatus == InGameStatus.postGame) {
      buttonText = '記録';
    }

    return Positioned(
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
        child: Text(buttonText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        onPressed: () => setState(() => {
              if (inGameStatus == InGameStatus.preGame)
                {inGameStatus = InGameStatus.inGame}
              else if (inGameStatus == InGameStatus.postGame)
                {
                  // チェック状況を記録する

                  // 記録しましたというスナックバーを表示
                  openSnackbar(),
                  // すべてのチェックボックスをfalseに戻す
                  checkboxListTileStateList.forEach((key, values) {
                    for (var value in values) {
                      value.checkboxValue = false;
                    }
                  }),

                  inGameStatus = InGameStatus.preGame
                }
              //ingameの場合は画面が灰色で押せないはずなので何もしない
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stacking = [
      Scaffold(
          appBar: _myMenuBar(gameChecklists),
          body: Stack(alignment: Alignment.topCenter, children: <Widget>[
            TabBarView(
                children: gameChecklists
                    .map((gameChecklist) => _myCheckItemsWidget(
                        gameChecklist.id,
                        inGameStatus == InGameStatus.postGame))
                    .toList()),
            gameStartusChangeButton()
          ]),
          floatingActionButton: myFloatingActionButton(context)),
    ];

    if (inGameStatus == InGameStatus.inGame) {
      final button = ElevatedButton(
        onPressed: () async {
          inGameStatus = InGameStatus.postGame;
          setState(() => ());
        },
        child: const Text(
          'GG',
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      );

      stacking.addAll([
        const Opacity(
          opacity: 0.8,
          child: ModalBarrier(dismissible: false, color: Colors.black),
        ),
        Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //textが赤色下黄色線になるのでMaterialで囲む
                children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Material(
                    color: Colors.transparent,
                    child: Text("ゲーム中",
                        style: TextStyle(fontSize: 40, color: Colors.white))),
                Icon(Icons.sports_gymnastics, color: Colors.white, size: 40)
              ]),
              button
            ]))
      ]);
    }

    return DefaultTabController(
        length: gameChecklists.length, //タブの数
        child: Stack(children: stacking));
  }
}
