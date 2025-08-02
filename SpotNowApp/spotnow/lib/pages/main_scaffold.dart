import 'package:flutter/material.dart';
import 'package:spotnow/elements/custom_bottom_nav_bar.dart';
import 'package:spotnow/pages/home_page.dart';

class MainScaffold extends StatefulWidget {
  final int userId;

  const MainScaffold({super.key, required this.userId});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  @override
  void initState() {
    super.initState();
    // Initialize the screens list in initState so you can use `widget.userId`.
    _screens = [
      HomePage(userId: widget.userId), // Pass the userId to the HomePage
      const Center(child: Text('Favourites Page')),
      const Center(child: Text('Add Page')),
      const Center(child: Text('Notifications Page')),
      const Center(child: Text('Profile Page')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true, // Allows the navbar to float above the content
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
