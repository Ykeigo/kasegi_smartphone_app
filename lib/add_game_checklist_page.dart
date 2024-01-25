import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddGameChecklistPage extends StatefulWidget {
  const AddGameChecklistPage({super.key});

  @override
  State<AddGameChecklistPage> createState() => _AddGameChecklistPageState();
}

class _AddGameChecklistPageState extends State<AddGameChecklistPage> {
  var name = "";

  void openSnackbar() {
    Get.snackbar(
      'ゲーム名が入力されていません',
      '名前を入力してください',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.black,
      colorText: Colors.white,
      borderRadius: 0,
      margin: const EdgeInsets.all(0),
    );
  }

  Future<bool> _backButtonPress(BuildContext context) async {
    bool? answer = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ゲームの追加を中止しますか？\n入力内容は破棄されます。'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('いいえ')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('はい'))
            ],
          );
        });

    return answer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ゲームの追加'),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          final NavigatorState navigator = Navigator.of(context);

          final doInterrupt = await _backButtonPress(context);
          if (doInterrupt) {
            navigator.pop(("", "")); // 戻るを選択した場合のみpopを明示的に呼ぶ
          }
        },
        child: Center(
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            onChanged: () {
              Form.of(primaryFocus!.context!).save();
            },
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tight(const Size(200, 50)),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'ゲーム名',
                    ),
                    onSaved: (String? value) {
                      name = value.toString();
                      debugPrint('Value for title saved as "$value"');
                    },
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tight(const Size(200, 50)),
                    child: ElevatedButton(
                      onPressed: () async {
                        final NavigatorState navigator = Navigator.of(context);
                        if (name.isEmpty) {
                          //snackbarが表示されていなければ表示する
                          if (!Get.isSnackbarOpen) {
                            openSnackbar();
                          }
                        } else {
                          navigator.pop(name); // 戻るを選択した場合のみpopを明示的に呼ぶ
                        }
                      },
                      child: const Text('作成'),
                    ),
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
