import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/behavior_streak_model.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/core/services/translation_service.dart';

class WeekDetailsDialog extends StatefulWidget {
  final int weekNumber;
  final String weekName;

  const WeekDetailsDialog({
    super.key,
    required this.weekNumber,
    required this.weekName,
  });

  @override
  State<WeekDetailsDialog> createState() => _WeekDetailsDialogState();
}

class _WeekDetailsDialogState extends State<WeekDetailsDialog> {
  final StudentRepository _repository = StudentRepository();
  final TranslationService _translationService = TranslationService();
  List<WeekDetailBehavior>? _behaviors;
  bool _isLoading = true;
  String? _error;
  final Map<String, String> _translatedTexts = {}; // Cache for translations

  @override
  void initState() {
    super.initState();
    _loadWeekDetails();
  }

  Future<void> _loadWeekDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final behaviors = await _repository.getWeekDetails(widget.weekNumber);

      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final isArabic = localeProvider.isArabic;

      for (var behavior in behaviors) {
        final cacheKey = '${behavior.behaviorNotes}_${isArabic ? 'ar' : 'en'}';

        if (!_translatedTexts.containsKey(cacheKey)) {
          try {
            // Detect source language and translate to target language
            final sourceLanguage = _translationService.detectLanguage(
              behavior.behaviorNotes,
            );

            if (isArabic && sourceLanguage == 'en') {
              _translatedTexts[cacheKey] = await _translationService
                  .translateToArabic(behavior.behaviorNotes);
            } else if (!isArabic && sourceLanguage == 'ar') {
              _translatedTexts[cacheKey] = await _translationService
                  .translateToEnglish(behavior.behaviorNotes);
            } else {
              // Same language or already translated
              _translatedTexts[cacheKey] = behavior.behaviorNotes;
            }
          } catch (e) {
            _translatedTexts[cacheKey] = behavior.behaviorNotes;
          }
        }
      }

      if (mounted) {
        setState(() {
          _behaviors = behaviors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getDayName(String dayName, BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (!localeProvider.isArabic) return dayName.toUpperCase();

    final arabicDays = {
      'SUN': 'أحد',
      'SUNDAY': 'أحد',
      'MON': 'إثنين',
      'MONDAY': 'إثنين',
      'TUE': 'ثلاثاء',
      'TUESDAY': 'ثلاثاء',
      'WED': 'أربعاء',
      'WEDNESDAY': 'أربعاء',
      'THU': 'خميس',
      'THURSDAY': 'خميس',
      'FRI': 'جمعة',
      'FRIDAY': 'جمعة',
      'SAT': 'سبت',
      'SATURDAY': 'سبت',
    };

    return arabicDays[dayName.toUpperCase()] ?? dayName;
  }

  Color _getBehaviorColor(String behaviorType) {
    switch (behaviorType.toUpperCase()) {
      case 'POSITIVE':
      case 'GOOD':
        return const Color(0xFF8BC34A); // Light Green
      case 'NEGATIVE':
      case 'BAD':
        return const Color(0xFFD32F2F); // Red
      case 'AVERAGE':
      case 'MIX':
      case 'MIXED':
        return const Color(0xFFFFB300); // Orange
      default:
        return Colors.grey;
    }
  }

  String _getBehaviorLabel(String behaviorType, BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    switch (behaviorType.toUpperCase()) {
      case 'POSITIVE':
      case 'GOOD':
        return localeProvider.isArabic ? 'سلوك جيد' : 'Good Behavior';
      case 'NEGATIVE':
      case 'BAD':
        return localeProvider.isArabic ? 'سلوك سيء' : 'Bad Behavior';
      case 'AVERAGE':
      case 'MIX':
      case 'MIXED':
        return localeProvider.isArabic ? 'سلوك متوسط' : 'Average Behavior';
      default:
        return behaviorType;
    }
  }

  String _formatDate(DateTime date, BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    if (localeProvider.isArabic) {
      // Arabic date format: "5 نوفمبر"
      final arabicMonths = {
        1: 'يناير',
        2: 'فبراير',
        3: 'مارس',
        4: 'أبريل',
        5: 'مايو',
        6: 'يونيو',
        7: 'يوليو',
        8: 'أغسطس',
        9: 'سبتمبر',
        10: 'أكتوبر',
        11: 'نوفمبر',
        12: 'ديسمبر',
      };
      return '${date.day} ${arabicMonths[date.month]}';
    } else {
      // English date format: "5th, Nov"
      final day = date.day;
      final suffix = (day >= 11 && day <= 13) || day % 10 == 0 || day % 10 > 3
          ? 'th'
          : (day % 10 == 1 ? 'st' : (day % 10 == 2 ? 'nd' : 'rd'));

      return '$day$suffix, ${DateFormat('MMM').format(date)}';
    }
  }

  // Group behaviors by day
  Map<String, List<WeekDetailBehavior>> _groupByDay() {
    if (_behaviors == null) return {};

    final grouped = <String, List<WeekDetailBehavior>>{};
    for (var behavior in _behaviors!) {
      // Create a unique key for grouping, but we'll display formatted date later
      final key = '${behavior.dayName}|${behavior.date.toIso8601String()}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(behavior);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.isArabic;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 700, maxWidth: 400),
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.weekName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFAA72A)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWeekDetails,
                child: Text(AppLocalizations.of(context)!.t('retry')),
              ),
            ],
          ),
        ),
      );
    }

    if (_behaviors == null || _behaviors!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppLocalizations.of(context)!.t('no_behavior_data'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final groupedBehaviors = _groupByDay();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedBehaviors.length,
      itemBuilder: (context, index) {
        final key = groupedBehaviors.keys.elementAt(index);
        final behaviors = groupedBehaviors[key]!;

        final parts = key.split('|');
        final dayName = parts[0];
        final date = DateTime.parse(parts[1]);

        return _buildDaySection(dayName, date, behaviors);
      },
    );
  }

  Widget _buildDaySection(
    String dayName,
    DateTime date,
    List<WeekDetailBehavior> behaviors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            '${_getDayName(dayName, context)} - ${_formatDate(date, context)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        // Behaviors for this day
        ...behaviors.map((behavior) => _buildBehaviorItem(behavior)),
      ],
    );
  }

  Widget _buildBehaviorItem(WeekDetailBehavior behavior) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.isArabic;

    final color = _getBehaviorColor(behavior.behaviorType);
    final label = _getBehaviorLabel(behavior.behaviorType, context);
    final points = behavior.totalPoints;
    final pointsText = points >= 0 ? '+$points XP' : '$points XP';

    final cacheKey = '${behavior.behaviorNotes}_${isArabic ? 'ar' : 'en'}';
    final displayNotes = _translatedTexts[cacheKey] ?? behavior.behaviorNotes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            padding: const EdgeInsets.all(8),
            child: Center(
              child: _getBehaviorIcon(behavior.behaviorType, color),
            ),
          ),
          const SizedBox(width: 12),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayNotes,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Points
          const SizedBox(width: 8),
          Text(
            pointsText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBehaviorIcon(String behaviorType, Color color) {
    switch (behaviorType.toUpperCase()) {
      case 'POSITIVE':
      case 'GOOD':
        return Transform.rotate(
          angle: 3.14159, // 180 degrees to point upward
          child: Image.asset(
            'assets/images/solar_like-linear.png',
            color: color,
            fit: BoxFit.contain,
          ),
        );
      case 'NEGATIVE':
      case 'BAD':
        return Image.asset(
          'assets/images/solar_like-linear (1).png',
          color: color,
          fit: BoxFit.contain,
        );
      case 'AVERAGE':
      case 'MIX':
      case 'MIXED':
        return Image.asset(
          'assets/images/fluent_thumb-like-dislike-24-regular.png',
          color: color,
          fit: BoxFit.contain,
        );
      default:
        return Icon(Icons.circle, color: color, size: 12);
    }
  }
}
