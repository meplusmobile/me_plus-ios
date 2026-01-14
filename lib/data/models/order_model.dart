class OrderModel {
  final int id;
  final int studentId;
  final String studentName;
  final String studentEmail;
  final int rewardId;
  final String status;
  final DateTime createdAt;
  final RewardInfo reward;

  OrderModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.rewardId,
    required this.status,
    required this.createdAt,
    required this.reward,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      rewardId: json['rewardId'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      reward: RewardInfo.fromJson(json['reward'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'rewardId': rewardId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'reward': reward.toJson(),
    };
  }
}

class RewardInfo {
  final int id;
  final String name;
  final String image;
  final int credits;
  final int levelIndex;

  RewardInfo({
    required this.id,
    required this.name,
    required this.image,
    required this.credits,
    required this.levelIndex,
  });

  factory RewardInfo.fromJson(Map<String, dynamic> json) {
    return RewardInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      credits: json['credits'] ?? 0,
      levelIndex: json['levelIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'credits': credits,
      'levelIndex': levelIndex,
    };
  }
}
