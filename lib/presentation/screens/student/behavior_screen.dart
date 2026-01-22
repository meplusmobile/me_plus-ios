import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/student/bottom_nav_bar.dart';
import 'package:me_plus/presentation/widgets/student/week_details_dialog.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/behavior_streak_model.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class BehaviorScreen extends StatefulWidget {
  const BehaviorScreen({super.key});

  @override
  State<BehaviorScreen> createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends State<BehaviorScreen> {
  final StudentRepository _repository = StudentRepository();
  BehaviorStreakResponse? _behaviorData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({int retryCount = 0}) async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _repository.getBehaviorStreak();

      if (mounted) {
        setState(() {
          _behaviorData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading behavior data: $e');
      
      // Retry logic for network errors (max 2 retries)
      if (retryCount < 2 && _shouldRetry(e.toString())) {
        debugPrint('🔄 Retrying behavior load (attempt ${retryCount + 1})...');
        await Future.delayed(Duration(seconds: 1 + retryCount));
        return _loadData(retryCount: retryCount + 1);
      }
      
      if (mounted) {
        setState(() {
          _error = _getUserFriendlyError(e.toString());
          _isLoading = false;
        });
      }
    }
  }
  
  /// Check if error should trigger a retry
  bool _shouldRetry(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('timeout') ||
           lowerError.contains('connection') ||
           lowerError.contains('socket') ||
           lowerError.contains('network');
  }
  
  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('timeout')) {
      return 'انتهت مهلة الاتصال';
    }
    if (lowerError.contains('socket') || lowerError.contains('connection')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return 'انتهت صلاحية الجلسة';
    }
    if (lowerError.contains('404')) {
      return 'لم يتم العثور على البيانات';
    }
    if (lowerError.contains('500') || lowerError.contains('server')) {
      return 'خطأ في الخادم';
    }
    
    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      return error.substring(11);
    }
    
    return error;
  }

  Future<void> _handleGiftTap() async {
    if (_behaviorData == null) {
      _showMessage(
        AppLocalizations.of(context)!.t('no_behavior_data'),
        isError: true,
      );
      return;
    }

    if (_behaviorData!.isGiven) {
      _showCustomDialog(
        icon: '✅',
        message: AppLocalizations.of(context)!.t('already_claimed_reward'),
        buttonText: AppLocalizations.of(context)!.t('ok'),
      );
      return;
    }

    if (!_behaviorData!.isEligible) {
      _showCustomDialog(
        icon: '🎁',
        message: AppLocalizations.of(
          context,
        )!.t('unlock_reward_no_bad_behavior'),
        buttonText: AppLocalizations.of(context)!.t('ok'),
      );
      return;
    }

    // Eligible to claim
    _showClaimDialog();
  }

  void _showCustomDialog({
    required String icon,
    required String message,
    required String buttonText,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              // Gift Icon
              Image.asset(
                'assets/images/Gift premium animation 2.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onConfirm != null) onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimDialog() {
    _showCustomDialog(
      icon: '🎉',
      message: AppLocalizations.of(
        context,
      )!.t('congratulations_eligible_reward'),
      buttonText: AppLocalizations.of(context)!.t('claim_reward'),
      onConfirm: _claimReward,
    );
  }

  Future<void> _claimReward() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      final result = await _repository.claimBehaviorReward();

      // Close loading
      if (mounted) Navigator.pop(context);

      // Reload data
      await _loadData();

      if (mounted) {
        final message = result['message']?.toString() ?? '';
        _showCustomDialog(
          icon: '🎉',
          message: message.isNotEmpty
              ? message
              : AppLocalizations.of(context)!.t('reward_claimed_successfully'),
          buttonText: AppLocalizations.of(context)!.t('ok'),
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        _showCustomDialog(
          icon: '❌',
          message:
              '${AppLocalizations.of(context)!.t('failed_to_claim_reward')}: ${e.toString()}',
          buttonText: AppLocalizations.of(context)!.t('ok'),
        );
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getWeekName(String weekName, BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    // Clean the name first
    final String cleanName = weekName
        .replaceAll('أسبوعي', '')
        .replaceAll('weekly', '')
        .replaceAll('Weekly', '')
        .trim();

    if (localeProvider.isArabic) {
      final arabicWeeks = {
        'First': 'الأسبوع الأول',
        'first': 'الأسبوع الأول',
        '1st': 'الأسبوع الأول',
        'Second': 'الأسبوع الثاني',
        'second': 'الأسبوع الثاني',
        '2nd': 'الأسبوع الثاني',
        'Third': 'الأسبوع الثالث',
        'third': 'الأسبوع الثالث',
        '3rd': 'الأسبوع الثالث',
        'Fourth': 'الأسبوع الرابع',
        'fourth': 'الأسبوع الرابع',
        '4th': 'الأسبوع الرابع',
        'Fifth': 'الأسبوع الخامس',
        'fifth': 'الأسبوع الخامس',
        '5th': 'الأسبوع الخامس',
        'Sixth': 'الأسبوع السادس',
        'sixth': 'الأسبوع السادس',
        '6th': 'الأسبوع السادس',
      };
      return arabicWeeks[cleanName] ?? cleanName;
    } else {
      final englishWeeks = {
        'First': '1st Week',
        'first': '1st Week',
        '1st': '1st Week',
        'Second': '2nd Week',
        'second': '2nd Week',
        '2nd': '2nd Week',
        'Third': '3rd Week',
        'third': '3rd Week',
        '3rd': '3rd Week',
        'Fourth': '4th Week',
        'fourth': '4th Week',
        '4th': '4th Week',
        'Fifth': '5th Week',
        'fifth': '5th Week',
        '5th': '5th Week',
        'Sixth': '6th Week',
        'sixth': '6th Week',
        '6th': '6th Week',
      };
      return englishWeeks[cleanName] ?? cleanName;
    }
  }

  String _getDayName(String dayName, BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (!localeProvider.isArabic) return dayName;

    // Clean the day name
    final String cleanName = dayName.trim().toUpperCase();

    // Map English day names to Arabic
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

    return arabicDays[cleanName] ?? dayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMonthSelector(),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
            const BottomNavBar(selectedIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gift Icon
          InkWell(
            onTap: () => _handleGiftTap(),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/gift.gif',
                  width: 48,
                  height: 48,
                ),
                if (_behaviorData != null &&
                    _behaviorData!.isEligible &&
                    !_behaviorData!.isGiven)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Image.asset(
                'assets/images/My purchases.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.t('behavior'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // Coins
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/Group 481842.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${profileProvider.credits}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)!.formatMonthYear(now),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text(AppLocalizations.of(context)!.t('retry')),
            ),
          ],
        ),
      );
    }

    if (_behaviorData == null || _behaviorData!.weeklyBehavior.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.t('no_behavior_data')),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _behaviorData!.weeklyBehavior.length,
      itemBuilder: (context, index) {
        return _buildWeekCard(_behaviorData!.weeklyBehavior[index], index);
      },
    );
  }

  Widget _buildWeekCard(WeeklyBehavior week, int index) {
    // Only first card is orange, rest are blue
    final color = index == 0 ? Colors.orange : const Color(0xFF7B96D4);

    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    ); // Normalize to midnight

    bool isCurrentWeek = false;
    if (week.days.isNotEmpty) {
      final sortedDays = week.days.map((d) => d.date).toList()..sort();
      final firstDay = sortedDays.first;
      final lastDay = sortedDays.last;

      // Normalize dates to midnight for comparison
      final firstDayNormalized = DateTime(
        firstDay.year,
        firstDay.month,
        firstDay.day,
      );
      final lastDayNormalized = DateTime(
        lastDay.year,
        lastDay.month,
        lastDay.day,
      );

      isCurrentWeek =
          (today.isAtSameMomentAs(firstDayNormalized) ||
              today.isAfter(firstDayNormalized)) &&
          (today.isAtSameMomentAs(lastDayNormalized) ||
              today.isBefore(lastDayNormalized));
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 8,
            bottom: 18,
          ), // Space for spiral and bottom
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          final weekName = _getWeekName(week.weekName, context);

                          return Text(
                            weekName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      if (isCurrentWeek) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1.5),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.t('this_week'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => WeekDetailsDialog(
                            weekNumber: week.weekNumber > 0
                                ? week.weekNumber
                                : index + 1,
                            weekName: _getWeekName(week.weekName, context),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/tabler_list-details.png',
                          width: 20,
                          height: 20,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate optimal spacing based on available width
                        // Each day item is ~38px wide, we have 7 days
                        // Available width minus the days width = space for gaps
                        final availableWidth = constraints.maxWidth;
                        const dayWidth = 38.0;
                        const totalDaysWidth = dayWidth * 7;
                        final totalGapSpace = availableWidth - totalDaysWidth;
                        final spacing = (totalGapSpace / 6).clamp(
                          4.0,
                          30.0,
                        ); // 6 gaps between 7 days

                        return Wrap(
                          spacing: spacing,
                          runSpacing: 8,
                          children: week.days
                              .map((day) => _buildDayItem(day))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Star on the bottom border
        Positioned(
          left: Provider.of<LocaleProvider>(context, listen: false).isArabic
              ? -7
              : null,
          right: Provider.of<LocaleProvider>(context, listen: false).isArabic
              ? null
              : -7,
          bottom: -5,
          child: _buildScoreStar(week.totalPointsForTheWeek),
        ),
        // Spiral Binding Effect (Vector.png)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              12,
              (index) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/images/Vector.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: 18,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/images/pointendofvector.png',
                        width: 8,
                        height: 8,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreStar(int score) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/star.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(DayBehavior day) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getDayName(day.dayName, context),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStatusColor(day.status), width: 2),
          ),
          child: Center(child: _getStatusIcon(day.status)),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'GOOD':
      case 'POSITIVE':
        return Colors.lightGreen;
      case 'BAD':
      case 'NEGATIVE':
        return Colors.red;
      case 'MIX':
      case 'MIXED':
        return Colors.orange;
      case 'NONE':
      default:
        return Colors.grey;
    }
  }

  Widget? _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'GOOD':
      case 'POSITIVE':
        return Transform.rotate(
          angle: 3.14159, // 180 degrees in radians (pi)
          child: Image.asset(
            'assets/images/solar_like-linear.png',
            width: 24,
            height: 24,
            color: Colors.lightGreen,
          ),
        );
      case 'BAD':
      case 'NEGATIVE':
        return Image.asset(
          'assets/images/solar_like-linear (1).png',
          width: 24,
          height: 24,
          color: Colors.red,
        );
      case 'MIX':
      case 'MIXED':
        return Image.asset(
          'assets/images/fluent_thumb-like-dislike-24-regular.png',
          width: 24,
          height: 24,
          color: Colors.orange,
        );
      case 'NONE':
      default:
        return null;
    }
  }
}
