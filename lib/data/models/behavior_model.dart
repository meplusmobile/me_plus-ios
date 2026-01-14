class BehaviorWeek {
  final String title;
  final bool isCurrentWeek;
  final int score;
  final List<DayBehavior> days;
  final DateTime startDate;

  BehaviorWeek({
    required this.title,
    required this.isCurrentWeek,
    required this.score,
    required this.days,
    required this.startDate,
  });

  factory BehaviorWeek.fromJson(Map<String, dynamic> json) {
    return BehaviorWeek(
      title: json['title'] ?? json['week_name'] ?? '',
      isCurrentWeek: json['is_current_week'] ?? json['isCurrentWeek'] ?? false,
      score: json['score'] ?? json['total_points'] ?? 0,
      days:
          (json['days'] as List?)
              ?.map((day) => DayBehavior.fromJson(day))
              .toList() ??
          [],
      startDate: DateTime.parse(
        json['start_date'] ??
            json['startDate'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'is_current_week': isCurrentWeek,
      'score': score,
      'days': days.map((d) => d.toJson()).toList(),
      'start_date': startDate.toIso8601String(),
    };
  }
}

class DayBehavior {
  final String dayName;
  final DateTime date;
  final bool hasGoodBehavior;
  final bool? isWeekend;
  final int points;

  DayBehavior({
    required this.dayName,
    required this.date,
    required this.hasGoodBehavior,
    this.isWeekend,
    required this.points,
  });

  factory DayBehavior.fromJson(Map<String, dynamic> json) {
    return DayBehavior(
      dayName: json['day_name'] ?? json['dayName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      hasGoodBehavior:
          json['has_good_behavior'] ?? json['hasGoodBehavior'] ?? false,
      isWeekend: json['is_weekend'] ?? json['isWeekend'],
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_name': dayName,
      'date': date.toIso8601String(),
      'has_good_behavior': hasGoodBehavior,
      'is_weekend': isWeekend,
      'points': points,
    };
  }
}

class BehaviorReport {
  final DateTime date;
  final int totalPoints;
  final int goodBehaviors;
  final int badBehaviors;
  final List<BehaviorDetail> behaviors;

  BehaviorReport({
    required this.date,
    required this.totalPoints,
    required this.goodBehaviors,
    required this.badBehaviors,
    required this.behaviors,
  });

  factory BehaviorReport.fromJson(Map<String, dynamic> json) {
    return BehaviorReport(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      totalPoints: json['total_points'] ?? json['totalPoints'] ?? 0,
      goodBehaviors: json['good_behaviors'] ?? json['goodBehaviors'] ?? 0,
      badBehaviors: json['bad_behaviors'] ?? json['badBehaviors'] ?? 0,
      behaviors:
          (json['behaviors'] as List?)
              ?.map((b) => BehaviorDetail.fromJson(b))
              .toList() ??
          [],
    );
  }
}

class BehaviorDetail {
  final int id;
  final String description;
  final String? descriptionAr;
  final String? descriptionEn;
  final int points;
  final bool isPositive;
  final DateTime createdAt;

  BehaviorDetail({
    required this.id,
    required this.description,
    this.descriptionAr,
    this.descriptionEn,
    required this.points,
    required this.isPositive,
    required this.createdAt,
  });

  factory BehaviorDetail.fromJson(Map<String, dynamic> json) {
    return BehaviorDetail(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      points: json['points'] ?? 0,
      isPositive: json['is_positive'] ?? json['isPositive'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  BehaviorDetail copyWith({
    int? id,
    String? description,
    String? descriptionAr,
    String? descriptionEn,
    int? points,
    bool? isPositive,
    DateTime? createdAt,
  }) {
    return BehaviorDetail(
      id: id ?? this.id,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      points: points ?? this.points,
      isPositive: isPositive ?? this.isPositive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BehaviorRecord {
  final int id;
  final String notes;
  final DateTime date;
  final int points;
  final int credits;
  final String behaviorType; // POSITIVE or NEGATIVE
  final String assignedByName;

  BehaviorRecord({
    required this.id,
    required this.notes,
    required this.date,
    required this.points,
    required this.credits,
    required this.behaviorType,
    required this.assignedByName,
  });

  factory BehaviorRecord.fromJson(Map<String, dynamic> json) {
    return BehaviorRecord(
      id: json['id'] ?? 0,
      notes: json['notes'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      points: json['points'] ?? 0,
      credits: json['credits'] ?? 0,
      behaviorType: json['behaviorType'] ?? 'POSITIVE',
      assignedByName: json['assignedByName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notes': notes,
      'date': date.toIso8601String(),
      'points': points,
      'credits': credits,
      'behaviorType': behaviorType,
      'assignedByName': assignedByName,
    };
  }

  bool get isPositive => behaviorType.toUpperCase() == 'POSITIVE';
  bool get isNegative => behaviorType.toUpperCase() == 'NEGATIVE';
}
