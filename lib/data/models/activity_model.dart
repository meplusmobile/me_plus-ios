class Activity {
  final int id;
  final String title;
  final String description;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final DateTime date;
  final String type;
  final int? points;
  final String? behaviorType; // POSITIVE, NEGATIVE, etc.

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.date,
    required this.type,
    this.points,
    this.behaviorType,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? json['notes'] ?? '',
      titleAr: json['title_ar'],
      titleEn: json['title_en'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      date: DateTime.parse(
        json['date'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      type: json['type'] ?? json['activity_type'] ?? 'general',
      points: json['points'],
      behaviorType: json['behaviorType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'date': date.toIso8601String(),
      'type': type,
      'points': points,
      'behaviorType': behaviorType,
    };
  }

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    DateTime? date,
    String? type,
    int? points,
    String? behaviorType,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      date: date ?? this.date,
      type: type ?? this.type,
      points: points ?? this.points,
      behaviorType: behaviorType ?? this.behaviorType,
    );
  }
}

class BehaviorDate {
  final DateTime date;
  final String behaviorStatus; // "None", "Positive", "Negative", "Mix"
  final String
  dayStatuses; // "Positive ,Negative" or "Positive ," or ",Negative" etc.

  BehaviorDate({
    required this.date,
    required this.behaviorStatus,
    required this.dayStatuses,
  });

  factory BehaviorDate.fromJson(Map<String, dynamic> json) {
    return BehaviorDate(
      date: DateTime.parse(json['date']),
      behaviorStatus: json['behaviorStatus'] ?? 'None',
      dayStatuses: json['dayStatuses'] ?? ',',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'behaviorStatus': behaviorStatus,
      'dayStatuses': dayStatuses,
    };
  }
}

class HonorListStudent {
  final int id;
  final String name;
  final String? levelName;
  final int points;
  final String? imageUrl;

  HonorListStudent({
    required this.id,
    required this.name,
    this.levelName,
    required this.points,
    this.imageUrl,
  });

  factory HonorListStudent.fromJson(Map<String, dynamic> json) {
    return HonorListStudent(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      levelName: json['levelName'],
      points: json['points'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'levelName': levelName,
      'points': points,
      'imageUrl': imageUrl,
    };
  }
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String? titleAr;
  final String? titleEn;
  final String? messageAr;
  final String? messageEn;
  final DateTime createdAt;
  final bool isRead;
  final String type;
  final String? imageUrl;
  final int? purchaseId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.titleAr,
    this.titleEn,
    this.messageAr,
    this.messageEn,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.imageUrl,
    this.purchaseId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse int
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return NotificationModel(
      id: parseId(json['id']),
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      titleAr: json['title_ar'],
      titleEn: json['title_en'],
      messageAr: json['message_ar'] ?? json['body_ar'],
      messageEn: json['message_en'] ?? json['body_en'],
      createdAt: DateTime.parse(
        json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      type: json['type'] ?? 'general',
      imageUrl:
          json['actionUserImageUrl'] ??
          json['action_user_image_url'] ??
          json['image_url'] ??
          json['imageUrl'],
      purchaseId: json['purchaseId'] ?? json['purchase_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'title_ar': titleAr,
      'title_en': titleEn,
      'message_ar': messageAr,
      'message_en': messageEn,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'image_url': imageUrl,
      'purchase_id': purchaseId,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    String? titleAr,
    String? titleEn,
    String? messageAr,
    String? messageEn,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? imageUrl,
    int? purchaseId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      messageAr: messageAr ?? this.messageAr,
      messageEn: messageEn ?? this.messageEn,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      purchaseId: purchaseId ?? this.purchaseId,
    );
  }
}
