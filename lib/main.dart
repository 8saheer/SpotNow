import 'package:flutter/material.dart';
import 'package:spotnow/pages/main_scaffold.dart';

void main() {
  runApp(const SpotNowApp());
}

class SpotNowApp extends StatelessWidget {
  const SpotNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: MainScaffold(),
    );
  }
}
