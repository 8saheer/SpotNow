import 'package:flutter/material.dart';
import 'package:spotnow/UserAuthService.dart';
import 'package:spotnow/pages/login_page.dart';
import 'package:spotnow/pages/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await UserAuthService.isLoggedIn();

  runApp(SpotNowApp(isLoggedIn: isLoggedIn));
}

class SpotNowApp extends StatelessWidget {
  final bool isLoggedIn;

  const SpotNowApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn ? const MainScaffold() : const LoginPage(),
    );
  }
}
