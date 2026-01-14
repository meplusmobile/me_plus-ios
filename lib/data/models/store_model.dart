class StoreReward {
  final int id;
  final String name;
  final String description;
  final int price;
  final String? image;
  final int stock;
  final bool isAvailable;

  StoreReward({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.stock,
    required this.isAvailable,
  });

  factory StoreReward.fromJson(Map<String, dynamic> json) {
    // Construct full image URL if only filename is provided
    String? imageUrl = json['image'] ?? json['image_url'];
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl = 'https://meplus2.blob.core.windows.net/images/$imageUrl';
    }

    return StoreReward(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? json['name'] ?? '',
      price: json['credits'] ?? json['price'] ?? json['points_required'] ?? 0,
      image: imageUrl,
      stock: json['stock'] ?? json['quantity'] ?? 999,
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'stock': stock,
      'is_available': isAvailable,
    };
  }
}

class Purchase {
  final int id;
  final int studentId;
  final int rewardId;
  final String rewardName;
  final int pointsSpent;
  final DateTime purchaseDate;
  final String status;
  final String? image;
  final String? market;
  final String? marketAddress;

  Purchase({
    required this.id,
    required this.studentId,
    required this.rewardId,
    required this.rewardName,
    required this.pointsSpent,
    required this.purchaseDate,
    required this.status,
    this.image,
    this.market,
    this.marketAddress,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    // Handle nested reward object
    String rewardName = '';
    int pointsSpent = 0;
    String? imageUrl;

    if (json['reward'] != null) {
      final reward = json['reward'];
      rewardName = reward['name'] ?? '';
      pointsSpent = reward['credits'] ?? 0;
      imageUrl = reward['image'];

      // Construct full image URL if only filename is provided
      if (imageUrl != null && !imageUrl.startsWith('http')) {
        imageUrl = 'https://meplus2.blob.core.windows.net/images/$imageUrl';
      }
    } else {
      rewardName = json['reward_name'] ?? json['rewardName'] ?? '';
      pointsSpent =
          json['points_spent'] ?? json['pointsSpent'] ?? json['price'] ?? 0;
      imageUrl = json['image'] ?? json['reward_image'];
    }

    return Purchase(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      rewardId:
          json['rewardId'] ?? json['reward_id'] ?? (json['reward']?['id'] ?? 0),
      rewardName: rewardName,
      pointsSpent: pointsSpent,
      purchaseDate: DateTime.parse(
        json['createdAt'] ??
            json['purchase_date'] ??
            json['purchaseDate'] ??
            json['created_at'] ??
            DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'pending',
      image: imageUrl,
      market: json['market'] ?? '',
      marketAddress: json['marketAddress'] ?? json['market_address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'reward_id': rewardId,
      'reward_name': rewardName,
      'points_spent': pointsSpent,
      'purchase_date': purchaseDate.toIso8601String(),
      'status': status,
      'image': image,
      'market': market,
      'marketAddress': marketAddress,
    };
  }
}
