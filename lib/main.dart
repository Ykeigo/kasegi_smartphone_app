import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

import 'package:flutter_application_1/checklist_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const Duration timeLimit = Duration(seconds: 5);

final logger = Logger();

void main() async {
  // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  _initGoogleMobileAds();
  runApp(const CheckboxListTileApp());
}

class CheckboxListTileApp extends StatelessWidget {
  const CheckboxListTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    //getxはスナックバーのために必要
    return GetMaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: "MPLUS_Rounded_1c"),
      home: SafeArea(child: ChecklistPage(key: super.key)),
    );
  }
}

Future<InitializationStatus> _initGoogleMobileAds() {
  // TODO: Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
}
