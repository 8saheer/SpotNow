import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black, // Black background
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.white // White for active tile
                        : Colors.white.withOpacity(0.2), // Slightly transparent white for inactive
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(index),
                    color: currentIndex == index
                        ? Colors.black // Black icon for active tile
                        : Colors.white, // White icon for inactive tile
                    size: 24,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined; // Changed to home icon for the first one based on image
      case 1:
        return Icons.bookmark_border; // Changed to bookmark icon
      case 2:
        return Icons.add_box_outlined; // Changed to add box icon
      case 3:
        return Icons.chat_bubble_outline; // Changed to chat icon
      case 4:
        return Icons.person_outline;
      default:
        return Icons.circle;
    }
  }
}