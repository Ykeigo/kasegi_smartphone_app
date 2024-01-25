import 'package:flutter/material.dart';
import 'package:flutter_application_1/db_helper.dart';
import 'package:flutter_application_1/add_game_checklist_item_page.dart';
import 'package:flutter_application_1/floating_button.dart';

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
  State<ChecklistPage> createState() => _CheckboxListTileExampleState();
}

class _CheckboxListTileExampleState extends State<ChecklistPage> {
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
              ChecklistItem(0, 0 /*デバッグ用に適当な値を入れています*/, result.$1, result.$2));
        }
        await reloadGameCheckItem();
        setState(() => ());
      },
      child: const Text('click here'),
    ));
    return DefaultTabController(
        length: 3, //タブの数
        child: Scaffold(
            appBar: MyMenuBar(),
            body: TabBarView(
              children: [
                Column(children: checkboxListTileWidgets),
                Icon(Icons.note),
                Icon(Icons.settings)
              ],
            ),
            floatingActionButton: MyFloatingActionButton()));
  }
}

class MyMenuBar extends StatefulWidget implements PreferredSizeWidget {
  final DbHelper dbHelper = DbHelper();
  MyMenuBar({super.key});

  @override
  State<MyMenuBar> createState() => _MyMenuBarState();

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);
}

class _MyMenuBarState extends State<MyMenuBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Center(child: Text('練習メニュー')),
      bottom: TabBar(tabs: [
        Icon(Icons.calendar_today),
        Icon(Icons.note),
        Icon(Icons.settings)
      ]),
    );
  }
}
