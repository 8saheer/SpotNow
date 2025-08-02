import 'package:flutter/material.dart';
import 'package:spotnow/UserAuthService.dart';
import 'package:spotnow/pages/login_page.dart';
import 'package:spotnow/pages/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We get the user ID directly. It will be null if not logged in.
  final userId = await UserAuthService.getUserId();

  runApp(SpotNowApp(userId: userId));
}

class SpotNowApp extends StatelessWidget {
  // Now the app holds the userId, which is nullable.
  final int? userId;

  const SpotNowApp({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1A237E), brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      // If userId is not null, it means the user is logged in.
      // We pass the userId to MainScaffold.
      home: userId != null ? MainScaffold(userId: userId!) : const LoginPage(),
    );
  }
}