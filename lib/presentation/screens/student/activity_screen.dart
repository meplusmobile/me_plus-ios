import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/student/bottom_nav_bar.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/services/prefetch_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final StudentRepository _repository = StudentRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Activity> _activities = [];
  Map<DateTime, Set<String>> _behaviorStatuses =
      {}; // date -> Set of behavior types
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthBehaviors();
      _loadActivities();
    });
  }

  Future<void> _loadMonthBehaviors() async {
    try {
      if (mounted) {
        setState(() {});
      }

      final monthStr = DateFormat('yyyy-MM').format(_focusedDay);
      final behaviorDates = await _repository.getActivity(date: monthStr);

      // Build a map that shows which behavior TYPES exist for each day based on dayStatuses
      final Map<DateTime, Set<String>> statuses = <DateTime, Set<String>>{};

      for (var item in behaviorDates) {
        final dateKey = DateTime(
          item.date.year,
          item.date.month,
          item.date.day,
        );

        // Initialize set if doesn't exist
        if (!statuses.containsKey(dateKey)) {
          statuses[dateKey] = <String>{};
        }

        // Parse dayStatuses to count positive and negative occurrences
        // dayStatuses format: "Positive ,Negative" or "Positive ," or ",Negative" or ","
        if (item.dayStatuses.isNotEmpty) {
          final parts = item.dayStatuses.split(',');
          int positiveCount = 0;
          int negativeCount = 0;

          // Count how many times each appears in the string
          for (var part in parts) {
            final trimmed = part.trim();
            if (trimmed == 'Positive') {
              positiveCount++;
            } else if (trimmed == 'Negative') {
              negativeCount++;
            }
          }

          // Determine what to show based on counts
          if (positiveCount > 0 || negativeCount > 0) {
            if (positiveCount > 0 && negativeCount == 0) {
              // All positive
              statuses[dateKey]!.add('AllPositive');
            } else if (negativeCount > 0 && positiveCount == 0) {
              // All negative
              statuses[dateKey]!.add('AllNegative');
            } else if (positiveCount == negativeCount) {
              // Equal positive and negative
              statuses[dateKey]!.add('Equal');
            } else if (positiveCount > negativeCount) {
              // More positive than negative (e.g., 2 positive vs 1 negative)
              statuses[dateKey]!.add('MorePositive');
            } else {
              // More negative than positive (e.g., 2 negative vs 1 positive)
              statuses[dateKey]!.add('MoreNegative');
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _behaviorStatuses = statuses;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadActivities() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final dateStr = DateFormat(
        'yyyy-M-d',
      ).format(_selectedDay ?? _focusedDay);
      final today = DateFormat('yyyy-M-d').format(DateTime.now());

      // Use cached data if loading today's activities
      final prefetchService = PrefetchService();
      if (dateStr == today && prefetchService.cachedActivities != null) {
        if (mounted) {
          setState(() {
            _activities = prefetchService.cachedActivities!;
            _isLoading = false;
          });
        }
        return;
      }

      final activities = await _repository.getBehaviorsByDay(date: dateStr);

      if (mounted) {
        setState(() {
          _activities = activities;
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

  Widget _buildDayCell(DateTime day, bool isSelected, bool isToday) {
    final dateKey = DateTime(day.year, day.month, day.day);
    final behaviorTypes = _behaviorStatuses[dateKey];

    // Build list of ovals to display
    final List<Widget> ovals = [];

    if (behaviorTypes != null && behaviorTypes.isNotEmpty) {
      final status = behaviorTypes.first; // Should only have one status

      if (status == 'AllPositive') {
        // All positive - show 1 green oval
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success, // Green
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'AllNegative') {
        // All negative - show 1 red oval
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight, // Red
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'Equal') {
        // Equal positive and negative - show 2 ovals (green + red)
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success, // Green
              shape: BoxShape.circle,
            ),
          ),
        );
        ovals.add(const SizedBox(width: 3));
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight, // Red
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'MorePositive') {
        // More positive than negative - show 3 ovals (2 green + 1 red)
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success, // Green
              shape: BoxShape.circle,
            ),
          ),
        );
        ovals.add(const SizedBox(width: 3));
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success, // Green
              shape: BoxShape.circle,
            ),
          ),
        );
        ovals.add(const SizedBox(width: 3));
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight, // Red
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'MoreNegative') {
        // More negative than positive - show 3 ovals (2 red + 1 green)
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight, // Red
              shape: BoxShape.circle,
            ),
          ),
        );
        ovals.add(const SizedBox(width: 3));
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight, // Red
              shape: BoxShape.circle,
            ),
          ),
        );
        ovals.add(const SizedBox(width: 3));
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success, // Green
              shape: BoxShape.circle,
            ),
          ),
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : isToday
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        if (ovals.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ovals,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildCalendar(),
                        const SizedBox(height: 24),
                        _buildActivitiesList(),
                      ],
                    ),
                  ),
                ),
              ),
              const BottomNavBar(selectedIndex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.bar_chart, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            isArabic ? 'النشاط' : 'Activity',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                  });
                  _loadMonthBehaviors();
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDay),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                    );
                  });
                  _loadMonthBehaviors();
                },
              ),
            ],
          ),
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadActivities();
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadMonthBehaviors();
            },
            calendarFormat: CalendarFormat.month,
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, true, false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, true);
              },
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              weekendTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
              weekendStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            ElevatedButton(
              onPressed: _loadActivities,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/box 1.png', width: 200, height: 200),
            const SizedBox(height: 16),
            const Text(
              'No Activity For today',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _activities.map((activity) {
        IconData icon;
        Color color;
        String pointsText = '';
        String title = '';

        // Check behaviorType first, then fall back to type
        final behaviorType =
            activity.behaviorType?.toUpperCase() ??
            activity.type.toUpperCase();

        switch (behaviorType) {
          case 'POSITIVE':
          case 'BEHAVIOR_POSITIVE':
          case 'GOOD':
            icon = Icons.thumb_up;
            color = AppColors.success;
            title = 'Good Behavior';
            pointsText = '+${activity.points ?? 0} XP';
            break;
          case 'NEGATIVE':
          case 'BEHAVIOR_NEGATIVE':
          case 'BAD':
            icon = Icons.thumb_down;
            color = AppColors.errorLight;
            title = 'Bad Behavior';
            pointsText = '-${(activity.points ?? 0).abs()} XP';
            break;
          case 'REWARD':
          case 'PURCHASE':
            icon = Icons.emoji_events;
            color = AppColors.primary;
            title = 'Reward';
            pointsText = (activity.points ?? 0) != 0
                ? '${activity.points} XP'
                : '';
            break;
          default:
            icon = Icons.info;
            color = AppColors.secondary;
            title = 'Activity';
            pointsText = (activity.points ?? 0) != 0
                ? '${activity.points} XP'
                : '';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildActivityCard(
            icon: icon,
            title: title,
            descriptionAr: activity.descriptionAr ?? activity.description,
            descriptionEn: activity.descriptionEn ?? activity.description,
            points: pointsText,
            color: color,
            isNegative: (activity.points ?? 0) < 0,
            context: context,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String descriptionAr,
    required String descriptionEn,
    required String points,
    required Color color,
    required bool isNegative,
    required BuildContext context,
  }) {
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;

    // Show description in user's selected language
    final description = isArabic ? descriptionAr : descriptionEn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (points.isNotEmpty)
            Text(
              points,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
