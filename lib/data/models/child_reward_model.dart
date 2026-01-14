class ChildReward {
  final int id;
  final String name;
  final String image;
  final int credits;

  ChildReward({
    required this.id,
    required this.name,
    required this.image,
    required this.credits,
  });

  factory ChildReward.fromJson(Map<String, dynamic> json) {
    return ChildReward(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      credits: json['credits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image, 'credits': credits};
  }

  // Helper to get full image URL
  String getImageUrl(String baseUrl) {
    if (image.startsWith('http')) {
      return image;
    }
    return '$baseUrl/uploads/$image';
  }
}
