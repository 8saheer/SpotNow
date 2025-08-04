import 'package:flutter/material.dart';
import 'package:spotnow/ApiServices/ApiService.dart';
import 'package:spotnow/models/landmark.dart';
import 'package:spotnow/pages/landmark_page.dart';

class LandmarkModule extends StatefulWidget {
  const LandmarkModule({
    super.key,
    required this.landmark,
    required this.userId,
  });

  final Landmark landmark;
  final int userId;

  @override
  State<LandmarkModule> createState() => _LandmarkModuleState();
}

class _LandmarkModuleState extends State<LandmarkModule> {
  late final ApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
  }

  void incrementView() async {
    try {
      final response = await apiService.post(
        'Landmark/AddViewIfNotVisited?userId=${widget.userId}&landmarkId=${widget.landmark.id}',
      );

      if (response.statusCode == 200) {
        print('View incremented or already visited.');
      } else {
        print('Failed to increment view. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error incrementing view: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        incrementView(),
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandmarkPage(
              landmarkId: widget.landmark.id,
              userId: widget.userId,
            ),
          ),
        ),
      },
      child: Container(
        width: 170, // Adjust width as needed based on your layout
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA), // Background color for the entire module
          borderRadius: BorderRadius.circular(
            10.0,
          ), // Slight corner radius for the module container
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align content to the left
          children: [
            // Image with rounded corners and golden star rating overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ), // Rounded corners for the image
                  child: Image.network(
                    widget.landmark.imageUrl,
                    width: double
                        .infinity, // Image takes full width of the container
                    height: 97, // Fixed height for the image
                    fit: BoxFit
                        .cover, // Cover the entire area without distortion
                    // Placeholder for when image is loading or fails
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 97,
                        color: Colors.grey[200], // Placeholder color
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 97,
                        color: Colors.grey[300], // Error placeholder color
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                // Golden star rating overlay (top-left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12, // Semi-transparent background
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ), // Rounded corners for rating box
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Wrap content tightly
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber, // Golden star color
                          size: 16.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.landmark.overallRating.toStringAsFixed(
                            1,
                          ), // Format to one decimal place
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content below the image (Name, Distance, Blue Star Rating)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 4,
              ), // Padding around the text content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Landmark Name
                      Expanded(
                        // Use Expanded to prevent overflow if name is long
                        child: Text(
                          widget.landmark.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Add ellipsis if text overflows
                        ),
                      ),
                      // Blue star rating (aligned to the right)
                      Row(
                        mainAxisSize: MainAxisSize.min, // Wrap content tightly
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary, // Blue star color
                            size: 16.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            widget.landmark.recentRating.toStringAsFixed(
                              1,
                            ), // Format to one decimal place
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4.0,
                  ), // Small space between name/rating and distance
                  // Distance
                  Text(
                    '${widget.landmark.distance.toStringAsFixed(1)} km',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
