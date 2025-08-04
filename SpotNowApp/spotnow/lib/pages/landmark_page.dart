import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotnow/ApiServices/ApiService.dart';

class LandmarkPage extends StatefulWidget {
  final int landmarkId;
  final int userId;

  const LandmarkPage({
    super.key,
    required this.landmarkId,
    required this.userId,
  });

  @override
  State<LandmarkPage> createState() => _LandmarkPageState();
}

class _LandmarkPageState extends State<LandmarkPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? landmarkInfo; // to store fetched landmark data
  Map<String, dynamic>? currentConditions;
  Map<String, dynamic>? landmarkDetails;
  bool _loadingTabData = false;
  bool _isLoading = true;

  final List<String> _placeholderImages = [
    'https://picsum.photos/600/400?random=1',
    'https://picsum.photos/600/400?random=2',
    'https://picsum.photos/600/400?random=3',
    'https://picsum.photos/600/400?random=4',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchLandmark();
    _fetchCurrentConditions();
    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) setState(() => _currentPage = next);
    });
  }

  Future<void> _fetchLandmark() async {
    try {
      final response = await _apiService.get(
        'Landmark/GetLandmark/${widget.landmarkId}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          landmarkInfo = data;
          _isLoading = false;
        });
      } else {
        // handle error: show message or fallback UI
        setState(() {
          _isLoading = false;
        });
        // optionally: print or log response.statusCode
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  Future<void> _fetchCurrentConditions() async {
    if (currentConditions != null) return; // Already fetched
    setState(() => _loadingTabData = true);
    try {
      final response = await _apiService.get(
        'LandmarkInformation/CurrentConditions/${widget.landmarkId}',
      );
      if (response.statusCode == 200) {
        setState(() {
          currentConditions = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() => _loadingTabData = false);
  }

  Future<void> _fetchLandmarkDetails() async {
    if (landmarkDetails != null) return; // Already fetched
    setState(() => _loadingTabData = true);
    try {
      final response = await _apiService.get(
        'LandmarkDetails/GetByLandmarkId/${widget.landmarkId}',
      );
      if (response.statusCode == 200) {
        setState(() {
          landmarkDetails = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
    setState(() => _loadingTabData = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _iconCircle(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 24,
        padding: EdgeInsets.zero,
        onPressed: onTap,
        splashRadius: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (landmarkInfo == null) {
      return Scaffold(
        body: Center(child: Text('Failed to load landmark data')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          // === CAROUSEL APP BAR ===
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              _iconCircle(Icons.share, () {}),
              _iconCircle(Icons.favorite_border, () {}),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Rounded carousel images
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _placeholderImages.length,
                      itemBuilder: (_, i) => Image.network(
                        _placeholderImages[i],
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, p) => p == null
                            ? child
                            : const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  ),

                  // Dots with adaptive rounded backdrop
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_placeholderImages.length, (
                            i,
                          ) {
                            final isActive = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 10 : 4,
                              height: isActive ? 10 : 4,
                              decoration: BoxDecoration(
                                color: isActive ? primary : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // === DETAILS CONTAINER ===
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    landmarkInfo!['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Ratings row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: primary, size: 20),
                          const SizedBox(width: 3),
                          Text(
                            landmarkInfo!['recentRating'].toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),

                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 3),
                          Text(
                            landmarkInfo!['overallRating'].toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 110),
                      Row(
                        children: [
                          Text(
                            landmarkInfo!['location'],
                            style: TextStyle(
                              fontFamily: 'Inter18',
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.location_on_sharp,
                            color: Colors.grey[700],
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(),
                  const SizedBox(height: 6),

                  // The tab buttons and content.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use a LayoutBuilder to get the parent's width reliably
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double tabWidth =
                              constraints.maxWidth / 2; // Assuming 2 tabs
                          return Stack(
                            children: [
                              Row(
                                children: [
                                  // Tab 1
                                  _tabButton(
                                    title: "Current Condition",
                                    index: 0,
                                    isActive: _selectedTab == 0,
                                    tabWidth: tabWidth,
                                  ),
                                  // Tab 2
                                  _tabButton(
                                    title: "Details",
                                    index: 1,
                                    isActive: _selectedTab == 1,
                                    tabWidth: tabWidth,
                                  ),
                                ],
                              ),
                              // The animated sliding line
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.fastEaseInToSlowEaseOut,
                                left: _selectedTab * tabWidth,
                                bottom: 0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(1.5),
                                  child: Container(
                                    height: 2,
                                    width: tabWidth,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _loadingTabData
                          ? const Center(child: CircularProgressIndicator())
                          : (_selectedTab == 0
                                ? getCurrentConditionContainer()
                                : getDetailsContainer()),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
    if (index == 0) {
      _fetchCurrentConditions();
    } else if (index == 1) {
      _fetchLandmarkDetails();
    }
  }

  // A helper method for creating the tab buttons.
  Widget _tabButton({
    required String title,
    required int index,
    required bool isActive,
    required double tabWidth,
  }) {
    return SizedBox(
      width: tabWidth,
      child: InkWell(
        onTap: () => _onTabSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isActive ? 18 : 16,
              color: isActive ? Theme.of(context).primaryColor : Colors.grey,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget getCurrentConditionContainer() {
  // Defensive checks in case some data is missing
  final crowdedness = currentConditions?['crowdednessRating'] ?? 'N/A';
  final bugs = currentConditions?['bugRating'] ?? 'N/A';
  final waterCleanliness = currentConditions?['waterCleanlinessRating'] ?? 'N/A';
  final parking = currentConditions?['parkingAvailable'];
  final noise = currentConditions?['noiseLevel'] ?? 'N/A';
  final smell = currentConditions?['smellRating'] ?? 'N/A';
  final picnic = currentConditions?['picnicSpotAvailable'];

  TextStyle labelStyle = TextStyle(
    fontFamily: 'Inter18',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: Colors.grey[800],
  );

  TextStyle valueStyle = TextStyle(
    fontFamily: 'Inter18',
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: Colors.black87,
  );

  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFEFEFEF),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConditionRow('👥 Crowdedness', crowdedness.toString(), labelStyle, valueStyle),
        _buildConditionRow('🐜 Bug Rating', bugs.toString(), labelStyle, valueStyle),
        _buildConditionRow('💧 Water Cleanliness', waterCleanliness.toString(), labelStyle, valueStyle),
        _buildConditionRow('🅿️ Parking Available', parking == null ? 'N/A' : (parking ? 'Yes' : 'No'), labelStyle, valueStyle),
        _buildConditionRow('🔊 Noise Level', noise.toString(), labelStyle, valueStyle),
        _buildConditionRow('👃 Smell Rating', smell.toString(), labelStyle, valueStyle),
        _buildConditionRow('🍽️ Picnic Spot', picnic == null ? 'N/A' : (picnic ? 'Yes' : 'No'), labelStyle, valueStyle),
      ],
    ),
  );
}

Widget _buildConditionRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    ),
  );
}

  getDetailsContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Inter24',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              landmarkInfo!['description'],
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                fontFamily: 'Inter18',
              ),
            ),

            const Divider(),
          ],
        ),
      ),
    );
  }
}
