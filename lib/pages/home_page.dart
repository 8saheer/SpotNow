import 'package:flutter/material.dart';
import 'package:spotnow/elements/category_module.dart';
import 'package:spotnow/elements/user_placeholder.dart';
import 'package:spotnow/models/landmark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  // List of categories for the filter chips
  final List<String> _categories = [
    'Show all',
    'Beaches',
    'Hiking',
    'National Parks',
  ];

  // A list to manage the selection state of the "Show all" chip.
  // We'll treat "Show all" as a special case for its icon.
  final List<bool> _selectedCategories = [
    true, // 'Show all' is initially selected
    false,
    false,
    false,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align children to the start
              children: [
                // Top Row: User Placeholder, SpotNow Text, Notification Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserPlaceholder(imageUrl: 'https://picsum.photos/150'),
                    const Text(
                      "SpotNow",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0.2),
                      decoration: BoxDecoration(
                        color: Color(0xFFEFEFEF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: Colors.grey[700],
                          size: 24.0,
                        ),
                        onPressed: () {
                          // notif page link
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: 14.0), // Space after the top row
                // "Where you heading?" Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: const Text(
                    "Where you heading?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0), // Space after the heading
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Color(
                      0xFFEFEFEF,
                    ), // White background for the search bar
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Maybe a beach?",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ), // Magnifying glass icon on the right
                      border: InputBorder.none, // Remove default border
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                    ),
                    onChanged: (value) {
                      // Implement search logic here
                      print('Search query: $value');
                    },
                  ),
                ),
                const SizedBox(height: 16.0), // Space after the search bar
                // Category Filter Chips
                SizedBox(
                  height: 40.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (index == 0) {
                                for (
                                  int i = 0;
                                  i < _selectedCategories.length;
                                  i++
                                ) {
                                  _selectedCategories[i] = (i == 0);
                                }
                              } else {
                                _selectedCategories[0] = false;
                                _selectedCategories[index] =
                                    !_selectedCategories[index];
                                if (!_selectedCategories.any(
                                  (e) => e && e != _selectedCategories[0],
                                )) {
                                  _selectedCategories[0] = true;
                                }
                              }
                            });
                            print('Tapped category: ${_categories[index]}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFFC2C2C2)
                                  : Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(
                                8.0,
                              ), // Slight corner rounding
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _categories[index],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isSelected)
                                  Row(
                                    children: const [
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            
                const SizedBox(height: 20),
            
                CategoryModule(
                  landmarks: [
                    Landmark(
                      id: 'l1',
                      imageUrl: 'https://picsum.photos/300/200?random=1',
                      overallRating: 4.3,
                      name: "Fun Beach 1",
                      distance: 14.3, // Changed to double
                      description: "A beautiful beach for relaxation.",
                      category: "Beach",
                      recentRating: 2.3,
                    ),
                    Landmark(
                      id: 'l2',
                      imageUrl: 'https://picsum.photos/300/200?random=2',
                      overallRating: 3.6,
                      name: "Halfway Log Dump",
                      distance: 59.4, // Changed to double
                      description:
                          "Scenic hiking trail with unique rock formations.",
                      category: "Hiking",
                      recentRating: 3.8,
                    ),
                    Landmark(
                      id: 'l3',
                      imageUrl: 'https://picsum.photos/300/200?random=3',
                      overallRating: 4.8,
                      name: "Wasaga Beach",
                      distance: 42.3, // Changed to double
                      description: "Longest freshwater beach in the world.",
                      category: "Beach",
                      recentRating: 4.5,
                    ),
                    Landmark(
                      id: 'l4',
                      imageUrl: 'https://picsum.photos/300/200?random=4',
                      overallRating: 4.9,
                      name: "West Edmonton Mall",
                      distance: 214.2, // Changed to double
                      description:
                          "One of the largest malls with an indoor water park.",
                      category: "Mall",
                      recentRating: 4.2,
                    ),
                    Landmark(
                      id: 'l5',
                      imageUrl: 'https://picsum.photos/300/200?random=5',
                      overallRating: 3.8,
                      name: "Toogood Pond Park",
                      distance: 2.1, // Changed to double
                      description:
                          "Peaceful park with walking trails and a pond.",
                      category: "Park",
                      recentRating: 1.2,
                    ),
                    Landmark(
                      id: 'l6',
                      imageUrl: 'https://picsum.photos/300/200?random=6',
                      overallRating: 4.1,
                      name: "Yoho National Park",
                      distance: 0.8, // Changed to double
                      description:
                          "Stunning national park with waterfalls and mountains.",
                      category: "National Park",
                      recentRating: 2.5,
                    ),
                  ],
                  categoryName: 'Popular Today',
                ),

                CategoryModule(
                  landmarks: [
                    Landmark(
                      id: 'l1',
                      imageUrl: 'https://picsum.photos/300/200?random=1',
                      overallRating: 4.3,
                      name: "Fun Beach 1",
                      distance: 14.3, // Changed to double
                      description: "A beautiful beach for relaxation.",
                      category: "Beach",
                      recentRating: 2.3,
                    ),
                    Landmark(
                      id: 'l2',
                      imageUrl: 'https://picsum.photos/300/200?random=2',
                      overallRating: 3.6,
                      name: "Halfway Log Dump",
                      distance: 59.4, // Changed to double
                      description:
                          "Scenic hiking trail with unique rock formations.",
                      category: "Hiking",
                      recentRating: 3.8,
                    ),
                    Landmark(
                      id: 'l3',
                      imageUrl: 'https://picsum.photos/300/200?random=3',
                      overallRating: 4.8,
                      name: "Wasaga Beach",
                      distance: 42.3, // Changed to double
                      description: "Longest freshwater beach in the world.",
                      category: "Beach",
                      recentRating: 4.5,
                    ),
                    Landmark(
                      id: 'l4',
                      imageUrl: 'https://picsum.photos/300/200?random=4',
                      overallRating: 4.9,
                      name: "West Edmonton Mall",
                      distance: 214.2, // Changed to double
                      description:
                          "One of the largest malls with an indoor water park.",
                      category: "Mall",
                      recentRating: 4.2,
                    ),
                    Landmark(
                      id: 'l5',
                      imageUrl: 'https://picsum.photos/300/200?random=5',
                      overallRating: 3.8,
                      name: "Toogood Pond Park",
                      distance: 2.1, // Changed to double
                      description:
                          "Peaceful park with walking trails and a pond.",
                      category: "Park",
                      recentRating: 1.2,
                    ),
                    Landmark(
                      id: 'l6',
                      imageUrl: 'https://picsum.photos/300/200?random=6',
                      overallRating: 4.1,
                      name: "Yoho National Park",
                      distance: 0.8, // Changed to double
                      description:
                          "Stunning national park with waterfalls and mountains.",
                      category: "National Park",
                      recentRating: 2.5,
                    ),
                  ],
                  categoryName: 'Popular Today',
                ),

                CategoryModule(
                  landmarks: [
                    Landmark(
                      id: 'l1',
                      imageUrl: 'https://picsum.photos/300/200?random=1',
                      overallRating: 4.3,
                      name: "Fun Beach 1",
                      distance: 14.3, // Changed to double
                      description: "A beautiful beach for relaxation.",
                      category: "Beach",
                      recentRating: 2.3,
                    ),
                    Landmark(
                      id: 'l2',
                      imageUrl: 'https://picsum.photos/300/200?random=2',
                      overallRating: 3.6,
                      name: "Halfway Log Dump",
                      distance: 59.4, // Changed to double
                      description:
                          "Scenic hiking trail with unique rock formations.",
                      category: "Hiking",
                      recentRating: 3.8,
                    ),
                    Landmark(
                      id: 'l3',
                      imageUrl: 'https://picsum.photos/300/200?random=3',
                      overallRating: 4.8,
                      name: "Wasaga Beach",
                      distance: 42.3, // Changed to double
                      description: "Longest freshwater beach in the world.",
                      category: "Beach",
                      recentRating: 4.5,
                    ),
                    Landmark(
                      id: 'l4',
                      imageUrl: 'https://picsum.photos/300/200?random=4',
                      overallRating: 4.9,
                      name: "West Edmonton Mall",
                      distance: 214.2, // Changed to double
                      description:
                          "One of the largest malls with an indoor water park.",
                      category: "Mall",
                      recentRating: 4.2,
                    ),
                    Landmark(
                      id: 'l5',
                      imageUrl: 'https://picsum.photos/300/200?random=5',
                      overallRating: 3.8,
                      name: "Toogood Pond Park",
                      distance: 2.1, // Changed to double
                      description:
                          "Peaceful park with walking trails and a pond.",
                      category: "Park",
                      recentRating: 1.2,
                    ),
                    Landmark(
                      id: 'l6',
                      imageUrl: 'https://picsum.photos/300/200?random=6',
                      overallRating: 4.1,
                      name: "Yoho National Park",
                      distance: 0.8, // Changed to double
                      description:
                          "Stunning national park with waterfalls and mountains.",
                      category: "National Park",
                      recentRating: 2.5,
                    ),
                  ],
                  categoryName: 'Popular Today',
                ),

                CategoryModule(
                  landmarks: [
                    Landmark(
                      id: 'l1',
                      imageUrl: 'https://picsum.photos/300/200?random=1',
                      overallRating: 4.3,
                      name: "Fun Beach 1",
                      distance: 14.3, // Changed to double
                      description: "A beautiful beach for relaxation.",
                      category: "Beach",
                      recentRating: 2.3,
                    ),
                    Landmark(
                      id: 'l2',
                      imageUrl: 'https://picsum.photos/300/200?random=2',
                      overallRating: 3.6,
                      name: "Halfway Log Dump",
                      distance: 59.4, // Changed to double
                      description:
                          "Scenic hiking trail with unique rock formations.",
                      category: "Hiking",
                      recentRating: 3.8,
                    ),
                    Landmark(
                      id: 'l3',
                      imageUrl: 'https://picsum.photos/300/200?random=3',
                      overallRating: 4.8,
                      name: "Wasaga Beach",
                      distance: 42.3, // Changed to double
                      description: "Longest freshwater beach in the world.",
                      category: "Beach",
                      recentRating: 4.5,
                    ),
                    Landmark(
                      id: 'l4',
                      imageUrl: 'https://picsum.photos/300/200?random=4',
                      overallRating: 4.9,
                      name: "West Edmonton Mall",
                      distance: 214.2, // Changed to double
                      description:
                          "One of the largest malls with an indoor water park.",
                      category: "Mall",
                      recentRating: 4.2,
                    ),
                    Landmark(
                      id: 'l5',
                      imageUrl: 'https://picsum.photos/300/200?random=5',
                      overallRating: 3.8,
                      name: "Toogood Pond Park",
                      distance: 2.1, // Changed to double
                      description:
                          "Peaceful park with walking trails and a pond.",
                      category: "Park",
                      recentRating: 1.2,
                    ),
                    Landmark(
                      id: 'l6',
                      imageUrl: 'https://picsum.photos/300/200?random=6',
                      overallRating: 4.1,
                      name: "Yoho National Park",
                      distance: 0.8, // Changed to double
                      description:
                          "Stunning national park with waterfalls and mountains.",
                      category: "National Park",
                      recentRating: 2.5,
                    ),
                  ],
                  categoryName: 'Popular Today',
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
