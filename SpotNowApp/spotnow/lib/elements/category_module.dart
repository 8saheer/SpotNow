import 'package:flutter/material.dart';
// Make sure this import path is correct for your project structure
import 'package:spotnow/models/landmark.dart';
// Make sure this import path is correct for your project structure
import 'package:spotnow/elements/landmark_module.dart';

class CategoryModule extends StatefulWidget {
  const CategoryModule({
    super.key,
    required this.landmarks,
    required this.categoryName, 
    required this.userId,
  });

  final List<Landmark> landmarks;
  final String categoryName;
  final int userId;

  @override
  State<CategoryModule> createState() => _CategoryModuleState();
}

class _CategoryModuleState extends State<CategoryModule> {

  @override
  Widget build(BuildContext context) {
    final List<Landmark> landmarksToDisplay = widget.landmarks;

    return Container(
      width: double.infinity,
      height: 200, // Adjusted height to comfortably fit title and a row of modules
      color: Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => {
                    print('tapped forward for ${widget.categoryName}')
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: landmarksToDisplay.length,
              itemBuilder: (context, index) {
                final landmark = landmarksToDisplay[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: LandmarkModule(landmark: landmark, userId: widget.userId,),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}