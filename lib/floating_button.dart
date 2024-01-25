import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_application_1/add_game_checklist_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:flutter_application_1/db_helper.dart';

final logger = Logger();

class MyFloatingActionButton extends StatelessWidget {
  final DbHelper dbHelper = DbHelper();

  MyFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.create),
            backgroundColor: Colors.blue,
            label: "ゲームを追加する",
            onTap: () async {
              logger.d(context);
              logger.d(Navigator);
              String result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddGameChecklistPage()),
              );
              logger.d("result: $result");
              await dbHelper.insertGameChecklist(GameChecklist(0, result));
              final games = await dbHelper.getGameChecklists();
              for (var game in games) {
                logger.d(game.name);
              }
            },
            labelStyle: const TextStyle(fontWeight: FontWeight.w500)),
      ],
      activeIcon: Icons.close,
      child: const Icon(Icons.add),
    );
  }
}
