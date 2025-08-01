class Landmark {
  final int id;
  final String name;
  final String description;
  final double distance;
  final String imageUrl;
  final double overallRating;
  final double recentRating;
  final List<String> categories;

  Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.imageUrl,
    required this.overallRating,
    required this.recentRating,
    required this.categories,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      distance: (json['distance'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      overallRating: (json['overallRating'] as num).toDouble(),
      recentRating: (json['recentRating'] as num).toDouble(),
      categories: List<String>.from(json['categories']),
    );
  }
}
