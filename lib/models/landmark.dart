class Landmark {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double distance;
  final String category; // e.g., "Museum", "Park", "Restaurant"
  final double overallRating;  // optional field
  final double recentRating;

  Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.distance,
    required this.category,
    required this.overallRating,
    required this.recentRating
  });

}
