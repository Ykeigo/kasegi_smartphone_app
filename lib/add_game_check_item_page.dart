import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldExample extends StatefulWidget {
  const TextFormFieldExample({super.key});

  @override
  State<TextFormFieldExample> createState() => _TextFormFieldExampleState();
}

class _TextFormFieldExampleState extends State<TextFormFieldExample> {
  var title = "";
  var subtitle = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('チェック項目の追加'),
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
            child: Shortcuts(
              shortcuts: const <ShortcutActivator, Intent>{
                // Pressing space in the field will now move to the next field.
                SingleActivator(LogicalKeyboardKey.space): NextFocusIntent(),
              },
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
                        onSaved: (String? value) {
                          title = value.toString();
                          debugPrint('Value for title saved as "$value"');
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tight(const Size(200, 50)),
                      child: TextFormField(
                        onSaved: (String? value) {
                          subtitle = value.toString();
                          debugPrint('Value for subtitle saved as "$value"');
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
                            final NavigatorState navigator =
                                Navigator.of(context);
                            navigator.pop(
                                (title, subtitle)); // 戻るを選択した場合のみpopを明示的に呼ぶ
                          },
                          child: const Text('作成'),
                        ),
                      ))
                ]),
              ),
            ),
          ),
        ));
  }
}

Future<bool> _backButtonPress(BuildContext context) async {
  bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('チェック項目の追加を中止しますか？\n入力内容は破棄されます。'),
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
