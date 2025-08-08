import 'dart:convert';
import 'package:intl/intl.dart';
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
  Map<String, dynamic>? landmarkInfo;
  Map<String, dynamic>? currentConditions;
  Map<String, dynamic>? landmarkDetails;
  List<dynamic>? landmarkComments;
  bool isLiked = false;
  bool _loadingTabData = false;
  bool _isLoading = true;
  bool _isPopupVisible = false; // New state variable for popup visibility

  // New state variables for the popup form
  int? _newCrowdednessRating;
  int? _newBugRating;
  int? _newWaterPurityRating;
  bool? _newParkingAvailable;
  int? _newNoiseLevel;
  int? _newSmellRating;
  bool? _newPicnicSpotAvailable;
  final TextEditingController _statusCommentController =
      TextEditingController(); // For the brief comment

  final List<String> _placeholderImages = [
    'https://picsum.photos/600/400?random=1',
    'https://picsum.photos/600/400?random=2',
    'https://picsum.photos/600/400?random=3',
    'https://picsum.photos/600/400?random=4',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedTab = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLandmark();
    _fetchCurrentConditions();
    _fetchLandmarkComments();
    _fetchIfLiked();
    _pageController.addListener(() {
      final next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) setState(() => _currentPage = next);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    _statusCommentController.dispose(); // Dispose new controller
    super.dispose();
  }

  // Method to toggle the popup's visibility
  void _togglePopup() {
    setState(() {
      _isPopupVisible = !_isPopupVisible;
    });
  }

  Future<void> _fetchLandmarkComments() async {
    try {
      final response = await _apiService.get(
        'Comments/GetCommentsOnLandmark/${widget.landmarkId}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          landmarkComments = data as List<dynamic>;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleLikedLandmark() async {
    try {
      final response = await _apiService.post(
        'Users/ToggleLikedLandmark/${widget.landmarkId}/${widget.userId}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLiked = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchIfLiked() async {
    try {
      final response = await _apiService.get(
        'Users/CheckIfLiked/${widget.landmarkId}/${widget.userId}',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLiked = data;
        });
      }
    } catch (e) {
      print(e);
    }
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
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  Future<void> _fetchCurrentConditions() async {
    if (currentConditions != null) return;
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
    if (landmarkDetails != null) return;
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

  Future<void> _sendComment() async {
    if (_commentController.text.isEmpty) {
      _showSnackBar("Comment cannot be empty!", Colors.orange);
      return;
    }

    final String content = _commentController.text;
    try {
      final response = await _apiService.post(
        'Comments/CreateComment/${widget.userId}/${widget.landmarkId}',
        body: jsonEncode({'content': content}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _commentController.clear();
        _showSnackBar("Comment Posted", Colors.green);
        await _fetchLandmarkComments();
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorCode = errorData['errorCode'];
          final errorMessage =
              errorData['errorMessage'] ?? "Failed to post comment";

          if (errorCode == 'EMPTY_COMMENT') {
            _showSnackBar("Comment cannot be empty!", Colors.orange);
          } else if (errorCode == 'COMMENT_TOO_SOON') {
            _showSnackBar(
              "You can only comment once per hour on this landmark.",
              Colors.orange,
            );
          } else {
            _showSnackBar("Error: $errorMessage", Colors.red);
          }
        } catch (_) {
          _showSnackBar("Error: Failed to post comment", Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  // New method to handle submitting the status update
  void _submitStatusUpdate() {
    // Here you would gather all the values from the state variables
    // and send them to your API.
    print("Submitting Status Update:");
    print("Crowdedness: $_newCrowdednessRating");
    print("Bug Rating: $_newBugRating");
    print("Water Purity: $_newWaterPurityRating");
    print("Parking Available: $_newParkingAvailable");
    print("Noise Level: $_newNoiseLevel");
    print("Smell Rating: $_newSmellRating");
    print("Picnic Spot Available: $_newPicnicSpotAvailable");
    print("Comment: ${_statusCommentController.text}");

    // You can add your API call here, similar to _sendComment
    // After submission, you might want to close the popup and refresh current conditions
    _togglePopup();
    // _fetchCurrentConditions(); // Uncomment to refresh after submission
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _iconCircle(
    IconData icon,
    VoidCallback onTap, {
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          iconSize: 24,
          padding: EdgeInsets.zero,
          onPressed: onTap,
          splashRadius: 10,
        ),
      ),
    );
  }

  // Helper to get rating value based on label
  int? _getRatingValue(String label) {
    switch (label) {
      case "Crowdedness":
        return _newCrowdednessRating;
      case "Bug Rating":
        return _newBugRating;
      case "Water Purity":
        return _newWaterPurityRating;
      case "Noise Level":
        return _newNoiseLevel;
      case "Smell Rating":
        return _newSmellRating;
      default:
        return null;
    }
  }

  // Helper to set rating value based on label
  void _setRatingValue(String label, int? value) {
    setState(() {
      switch (label) {
        case "Crowdedness":
          _newCrowdednessRating = value;
          break;
        case "Bug Rating":
          _newBugRating = value;
          break;
        case "Water Purity":
          _newWaterPurityRating = value;
          break;
        case "Noise Level":
          _newNoiseLevel = value;
          break;
        case "Smell Rating":
          _newSmellRating = value;
          break;
      }
    });
  }

  // Helper to get Yes/No value based on label
  bool? _getYesNoValue(String label) {
    switch (label) {
      case "Parking":
        return _newParkingAvailable;
      case "Picnic Spot":
        return _newPicnicSpotAvailable;
      default:
        return null;
    }
  }

  // Helper to set Yes/No value based on label
  void _setYesNoValue(String label, bool? value) {
    setState(() {
      switch (label) {
        case "Parking":
          _newParkingAvailable = value;
          break;
        case "Picnic Spot":
          _newPicnicSpotAvailable = value;
          break;
      }
    });
  }

  // Helper widget for 1-5 rating selectors with an icon and text field
// Helper widget for rating inputs (1-5)
Widget _buildRatingInput({
  required IconData icon,
  required String label,
  required int? currentValue,
  required Function(int?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        // Icon in a sleek rounded square
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        // Label and input field
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: TextEditingController(text: currentValue?.toString() ?? ''),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "1-5",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  ),
                  onChanged: (text) {
                    final int? value = int.tryParse(text);
                    if (value != null && value >= 1 && value <= 5) {
                      onChanged(value);
                    } else if (text.isEmpty) {
                      onChanged(null);
                    }
                  },
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper widget for Yes/No selectors with an icon
Widget _buildYesNoInput({
  required IconData icon,
  required String label,
  required bool? currentValue,
  required Function(bool?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        // Icon in a sleek rounded square
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSelectionButton(
                      label: 'Yes',
                      isSelected: currentValue == true,
                      onTap: () => onChanged(true),
                    ),
                    _buildSelectionButton(
                      label: 'No',
                      isSelected: currentValue == false,
                      onTap: () => onChanged(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSelectionButton({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 60,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.9)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
    ),
  );
}

// The updated popup container
Widget _buildPopUpContainer() {
  if (!_isPopupVisible) {
    return const SizedBox.shrink();
  }

  final List<Map<String, dynamic>> statusItems = [
    {"icon": Icons.groups, "label": "Crowdedness", "type": "rating"},
    {"icon": Icons.bug_report, "label": "Bug Rating", "type": "rating"},
    {"icon": Icons.water, "label": "Water Purity", "type": "rating"},
    {"icon": Icons.local_parking, "label": "Parking", "type": "yes_no"},
    {"icon": Icons.volume_up, "label": "Noise Level", "type": "rating"},
    {"icon": Icons.smoking_rooms, "label": "Smell Rating", "type": "rating"},
    {"icon": Icons.park, "label": "Picnic Spot", "type": "yes_no"},
  ];

  return Stack(
    children: [
      // Dark overlay for background
      GestureDetector(
        onTap: _togglePopup,
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
      // Popup container
      Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Make a Status Update",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey, size: 28),
          onPressed: _togglePopup,
        ),
      ],
    ),
    const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: statusItems.map((item) {
                      if (item["type"] == "rating") {
                        return _buildRatingInput(
                          icon: item["icon"] as IconData,
                          label: item["label"] as String,
                          currentValue: _getRatingValue(item["label"] as String),
                          onChanged: (value) => _setRatingValue(item["label"] as String, value),
                        );
                      } else if (item["type"] == "yes_no") {
                        return _buildYesNoInput(
                          icon: item["icon"] as IconData,
                          label: item["label"] as String,
                          currentValue: _getYesNoValue(item["label"] as String),
                          onChanged: (value) => _setYesNoValue(item["label"] as String, value),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Brief Comment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _statusCommentController,
                decoration: InputDecoration(
                  hintText: "Share your thoughts...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitStatusUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Submit Status Update",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (landmarkInfo == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load landmark data')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
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
                  _iconCircle(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    () => _toggleLikedLandmark(),
                    iconColor: isLiked ? Colors.red : Colors.white,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
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
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
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
                              children: List.generate(
                                _placeholderImages.length,
                                (i) {
                                  final isActive = i == _currentPage;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: isActive ? 10 : 4,
                                    height: isActive ? 10 : 4,
                                    decoration: BoxDecoration(
                                      color: isActive ? primary : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            landmarkInfo!['name'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(
                                0.2,
                              ), // Slightly transparent green
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Last update 8d ago", // Hardcoded for now
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: primary, size: 20),
                              const SizedBox(width: 3),
                              Text(
                                landmarkInfo!['recentRating'].toStringAsFixed(
                                  1,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                landmarkInfo!['overallRating'].toStringAsFixed(
                                  1,
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double tabWidth = constraints.maxWidth / 2;
                              return Stack(
                                children: [
                                  Row(
                                    children: [
                                      _tabButton(
                                        "Current Condition",
                                        0,
                                        _selectedTab == 0,
                                        tabWidth,
                                      ),
                                      _tabButton(
                                        "Details",
                                        1,
                                        _selectedTab == 1,
                                        tabWidth,
                                      ),
                                    ],
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 150),
                                    curve: Curves.fastEaseInToSlowEaseOut,
                                    left: _selectedTab * tabWidth,
                                    bottom: 0,
                                    child: Container(
                                      height: 2,
                                      width: tabWidth,
                                      color: primary,
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
          _buildPopUpContainer(), // Add the popup as a layer on top
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

  Widget _tabButton(String title, int index, bool isActive, double tabWidth) {
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
    final items = [
      {
        "icon": Icons.groups,
        "label": "Crowdedness",
        "value": currentConditions?['crowdednessRating'] ?? 'N/A',
      },
      {
        "icon": Icons.bug_report,
        "label": "Bug Rating",
        "value": currentConditions?['bugRating'] ?? 'N/A',
      },
      {
        "icon": Icons.water,
        "label": "Water Purity",
        "value": currentConditions?['waterCleanlinessRating'] ?? 'N/A',
      },
      {
        "icon": Icons.local_parking,
        "label": "Parking",
        "value": currentConditions?['parkingAvailable'] == null
            ? 'N/A'
            : (currentConditions?['parkingAvailable'] ? 'Yes' : 'No'),
      },
      {
        "icon": Icons.volume_up,
        "label": "Noise Level",
        "value": currentConditions?['noiseLevel'] ?? 'N/A',
      },
      {
        "icon": Icons.smoking_rooms,
        "label": "Smell Rating",
        "value": currentConditions?['smellRating'] ?? 'N/A',
      },
      {
        "icon": Icons.park,
        "label": "Picnic Spot",
        "value": currentConditions?['picnicSpotAvailable'] == null
            ? 'N/A'
            : (currentConditions?['picnicSpotAvailable'] ? 'Yes' : 'No'),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Status",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              // Use the _togglePopup method here
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: 35,
                child: ElevatedButton(
                  onPressed: _togglePopup, // This will open the popup
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 0,
                  ),
                  child: const Center(
                    child: Text(
                      "Make a status update",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
          ...List.generate((items.length / 2).ceil(), (index) {
            final firstItemIndex = index * 2;
            final secondItemIndex = firstItemIndex + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _buildConditionItem(
                      icon: items[firstItemIndex]["icon"] as IconData,
                      label: items[firstItemIndex]["label"] as String,
                      value: items[firstItemIndex]["value"].toString(),
                    ),
                  ),
                  if (secondItemIndex < items.length) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildConditionItem(
                        icon: items[secondItemIndex]["icon"] as IconData,
                        label: items[secondItemIndex]["label"] as String,
                        value: items[secondItemIndex]["value"].toString(),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Comments",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Inter24',
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: _fetchLandmarkComments,
                icon: const Icon(Icons.refresh, color: Colors.black54),
                tooltip: 'Refresh Comments',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFilterOption(
                label: 'Date',
                icon: Icons.keyboard_arrow_down,
              ),
              const SizedBox(width: 8),
              _buildFilterOption(
                label: 'Rating',
                icon: Icons.keyboard_arrow_down,
              ),
              const SizedBox(width: 8),
              _buildFilterOption(
                label: 'Recent',
                icon: Icons.keyboard_arrow_down,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: landmarkComments == null
                    ? const Center(child: CircularProgressIndicator())
                    : landmarkComments!.isEmpty
                    ? const Center(
                        child: Text(
                          "No comments yet.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          right: 12,
                        ),
                        itemCount: landmarkComments!.length,
                        itemBuilder: (context, index) {
                          final comment =
                              landmarkComments![landmarkComments!.length -
                                  1 -
                                  index];
                          return _buildCommentItem(comment);
                        },
                      ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFAFAFA),
                          const Color(0xFFFAFAFA).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFFFAFAFA),
                          const Color(0xFFFAFAFA).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Write a message...",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: _sendComment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Icon(icon, size: 18, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildConditionItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    String formattedDate = '';
    try {
      if (comment['date'] != null) {
        DateTime parsedDate = DateTime.parse(comment['date']);
        formattedDate = DateFormat(
          'MMM d, yyyy • h:mm a',
        ).format(parsedDate.toLocal());
      }
    } catch (e) {
      formattedDate = comment['date'] ?? '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment['name'] ?? 'Anonymous',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter18',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: 'Inter18',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment['content'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter18',
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getDetailsContainer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
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
          Text(
            landmarkInfo!['description'],
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              fontFamily: 'Inter18',
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
