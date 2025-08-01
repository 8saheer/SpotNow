import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:spotnow/ApiServices/ApiService.dart';
import 'package:spotnow/elements/category_module.dart';
import 'package:spotnow/elements/user_placeholder.dart';
import 'package:spotnow/models/landmark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final ApiService apiService;
  late String response;

  List<Landmark> landmarks = [];

  Future<void> getApiResponse() async {
  try {
    final result = await apiService.get("Landmark/GetLandmarks");

    if (result.statusCode >= 200 && result.statusCode <= 209) {
      final List<dynamic> jsonData = jsonDecode(result.body);
      setState(() {
        landmarks = jsonData.map((e) => Landmark.fromJson(e)).toList();
      });
    }
  } catch (e) {
    print('Error fetching landmarks: $e');
  }
}

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    getApiResponse();
  }
  
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Show all',
    'Beaches',
    'Hiking',
    'National Parks',
  ];

  final List<bool> _selectedCategories = [
    true,
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
      extendBody: true,
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Column(
          children: [
            // Fixed top row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UserPlaceholder(imageUrl: 'https://picsum.photos/150'),
                  const Text(
                    "SpotNow",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0.2),
                    decoration: const BoxDecoration(
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
            ),

            // Scrollable content below
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Where you heading?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Maybe a beach?",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 10.0,
                          ),
                        ),
                        onChanged: (value) {
                          print('Search query: $value');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
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
                                    for (int i = 0; i < _selectedCategories.length; i++) {
                                      _selectedCategories[i] = (i == 0);
                                    }
                                  } else {
                                    _selectedCategories[0] = false;
                                    _selectedCategories[index] = !_selectedCategories[index];
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFC2C2C2) : const Color(0xFFEFEFEF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _categories[index],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (isSelected)
                                      const Row(
                                        children: [
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

                    CategoryModule(landmarks: landmarks, categoryName: "Popular Today")

                    // Add additional CategoryModule widgets here if needed.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
