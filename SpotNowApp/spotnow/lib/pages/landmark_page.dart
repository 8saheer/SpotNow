import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:spotnow/ApiServices/ApiService.dart';
import 'package:spotnow/elements/custom_button.dart';

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
    super.dispose();
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
      body: CustomScrollView(
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
                            : const Center(child: CircularProgressIndicator()),
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
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            landmarkInfo!['recentRating'].toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 3),
                          Text(
                            landmarkInfo!['overallRating'].toStringAsFixed(1),
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

              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle status update action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 0,
                  ),
                  child: Center(
                    child: const Text(
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
