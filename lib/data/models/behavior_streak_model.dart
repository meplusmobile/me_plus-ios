class BehaviorStreakResponse {
  final List<WeeklyBehavior> weeklyBehavior;
  final bool isEligible;
  final bool isGiven;

  BehaviorStreakResponse({
    required this.weeklyBehavior,
    required this.isEligible,
    required this.isGiven,
  });

  factory BehaviorStreakResponse.fromJson(Map<String, dynamic> json) {
    return BehaviorStreakResponse(
      weeklyBehavior:
          (json['weeklyBehavior'] as List?)
              ?.map((w) => WeeklyBehavior.fromJson(w))
              .toList() ??
          [],
      isEligible: json['isEligible'] ?? false,
      isGiven: json['isGiven'] ?? false,
    );
  }
}

class WeeklyBehavior {
  final String weekName;
  final List<DayBehavior> days;
  final int totalPointsForTheWeek;
  final int weekNumber;

  WeeklyBehavior({
    required this.weekName,
    required this.days,
    required this.totalPointsForTheWeek,
    this.weekNumber = 0,
  });

  factory WeeklyBehavior.fromJson(Map<String, dynamic> json) {
    return WeeklyBehavior(
      weekName: json['weekName'] ?? '',
      days:
          (json['days'] as List?)
              ?.map((d) => DayBehavior.fromJson(d))
              .toList() ??
          [],
      totalPointsForTheWeek: json['totalPointsForTheWeek'] ?? 0,
      weekNumber: json['weekNumber'] ?? 0,
    );
  }
}

class DayBehavior {
  final String dayName;
  final DateTime date;
  final String status; // "NONE", "GOOD", "BAD", "MIX"
  final int points;
  final int credits;

  DayBehavior({
    required this.dayName,
    required this.date,
    required this.status,
    required this.points,
    required this.credits,
  });

  factory DayBehavior.fromJson(Map<String, dynamic> json) {
    return DayBehavior(
      dayName: json['dayName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'NONE',
      points: json['points'] ?? 0,
      credits: json['credits'] ?? 0,
    );
  }
}

class WeekDetailBehavior {
  final int weekNumber;
  final String dayName;
  final DateTime date;
  final String behaviorType; // "POSITIVE", "NEGATIVE"
  final String behaviorNotes;
  final String? behaviorNotesAr;
  final String? behaviorNotesEn;
  final int totalPoints;
  final int totalCredits;

  WeekDetailBehavior({
    required this.weekNumber,
    required this.dayName,
    required this.date,
    required this.behaviorType,
    required this.behaviorNotes,
    this.behaviorNotesAr,
    this.behaviorNotesEn,
    required this.totalPoints,
    required this.totalCredits,
  });

  factory WeekDetailBehavior.fromJson(Map<String, dynamic> json) {
    return WeekDetailBehavior(
      weekNumber: json['weekNumber'] ?? 0,
      dayName: json['dayName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      behaviorType: json['behaviorType'] ?? '',
      behaviorNotes: json['behaviorNotes'] ?? '',
      behaviorNotesAr: json['behaviorNotesAr'] ?? json['behaviorNotes_ar'],
      behaviorNotesEn: json['behaviorNotesEn'] ?? json['behaviorNotes_en'],
      totalPoints: json['totalPoints'] ?? 0,
      totalCredits: json['totalCredits'] ?? 0,
    );
  }
}
