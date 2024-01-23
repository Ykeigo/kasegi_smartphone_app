import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddGameChecklistPage extends StatefulWidget {
  const AddGameChecklistPage({super.key});

  @override
  State<AddGameChecklistPage> createState() => _AddGameChecklistPageState();
}

class _AddGameChecklistPageState extends State<AddGameChecklistPage> {
  var title = "";
  var subtitle = "";

  void openSnackbar() {
    Get.snackbar(
      '項目名が入力されていません',
      '項目名を入力してください',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.black,
      colorText: Colors.white,
      borderRadius: 0,
      margin: const EdgeInsets.all(0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('チェック項目の追加'),
        ),
        body: const Text("hello"));
  }
}
