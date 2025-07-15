import 'package:flutter/material.dart';
import 'screens/barcode_scanner_page.dart';
import 'package:fitquest/widgets/popup_log.dart';
import 'screens/main_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitQuest',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: const MainPageDesign(),
    );
  }
}
