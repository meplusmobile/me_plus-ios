class ChildReport {
  final int totalPointsGiven;
  final int totalCreditsGiven;
  final double totalPointsExchanged;
  final double totalCreditsExchanged;
  final int positiveCount;
  final int negativeCount;
  final String childName;

  ChildReport({
    required this.totalPointsGiven,
    required this.totalCreditsGiven,
    required this.totalPointsExchanged,
    required this.totalCreditsExchanged,
    required this.positiveCount,
    required this.negativeCount,
    required this.childName,
  });

  // Calculate total behavior count
  int get totalBehaviors => positiveCount + negativeCount;

  // Calculate percentage for donut chart
  double get positivePercentage {
    if (totalBehaviors == 0) return 0;
    return (positiveCount / totalBehaviors) * 100;
  }

  double get negativePercentage {
    if (totalBehaviors == 0) return 0;
    return (negativeCount / totalBehaviors) * 100;
  }

  factory ChildReport.empty() {
    return ChildReport(
      totalPointsGiven: 0,
      totalCreditsGiven: 0,
      totalPointsExchanged: 0,
      totalCreditsExchanged: 0,
      positiveCount: 0,
      negativeCount: 0,
      childName: '',
    );
  }

  ChildReport copyWith({
    int? totalPointsGiven,
    int? totalCreditsGiven,
    double? totalPointsExchanged,
    double? totalCreditsExchanged,
    int? positiveCount,
    int? negativeCount,
    String? childName,
  }) {
    return ChildReport(
      totalPointsGiven: totalPointsGiven ?? this.totalPointsGiven,
      totalCreditsGiven: totalCreditsGiven ?? this.totalCreditsGiven,
      totalPointsExchanged: totalPointsExchanged ?? this.totalPointsExchanged,
      totalCreditsExchanged:
          totalCreditsExchanged ?? this.totalCreditsExchanged,
      positiveCount: positiveCount ?? this.positiveCount,
      negativeCount: negativeCount ?? this.negativeCount,
      childName: childName ?? this.childName,
    );
  }
}
