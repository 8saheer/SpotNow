import 'package:flutter/material.dart';

class UserPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double radius; // Define radius for size control

  const UserPlaceholder({
    super.key,
    required this.imageUrl,
    this.radius = 22.0, // Default radius
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300], // Placeholder background color
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Optional: Handle errors if the image fails to load
        // You could log the error or display a different icon
        debugPrint('Error loading image: $exception');
      },
      child: imageUrl.isEmpty // Show an icon if imageUrl is empty or null
          ? Icon(
              Icons.person,
              size: radius * 1.2, // Adjust icon size based on radius
              color: Colors.grey[600],
            )
          : null, // No child needed if an image is loaded
    );
  }
}