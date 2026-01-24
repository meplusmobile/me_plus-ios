import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/data/repositories/parent_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/child_model.dart';
import 'package:me_plus/presentation/providers/children_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class ChildActivityScreen extends StatefulWidget {
  final String kidId;

  const ChildActivityScreen({super.key, required this.kidId});

  @override
  State<ChildActivityScreen> createState() => _ChildActivityScreenState();
}

class _ChildActivityScreenState extends State<ChildActivityScreen> {
  final ParentRepository _repository = ParentRepository();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Activity> _activities = [];
  Map<DateTime, Set<String>> _behaviorStatuses =
      {}; // date -> Set of behavior types
  bool _isLoading = false;
  String? _error;
  Child? _child;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChild();
      _loadMonthBehaviors();
      _loadDayBehaviors();
    });
  }

  void _loadChild() {
    final childrenProvider = context.read<ChildrenProvider>();
    _child = childrenProvider.getChildById(widget.kidId);
  }

  Future<void> _loadMonthBehaviors() async {
    if (_child == null) return;

    try {
      if (mounted) {
        setState(() {});
      }

      final monthStr = DateFormat('yyyy-MM').format(_focusedDay);
      final behaviorDates = await _repository.getChildActivity(
        schoolId: _child!.schoolId,
        classId: _child!.classId,
        childId: widget.kidId,
        date: monthStr,
      );

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

  Future<void> _loadDayBehaviors() async {
    if (_child == null) return;

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
      final activities = await _repository.getChildBehaviorsByDay(
        schoolId: _child!.schoolId,
        classId: _child!.classId,
        childId: widget.kidId,
        date: dateStr,
      );

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
      final status = behaviorTypes.first;

      if (status == 'AllPositive') {
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'AllNegative') {
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'Equal') {
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
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
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'MorePositive') {
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
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
              color: AppColors.success,
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
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (status == 'MoreNegative') {
        ovals.add(
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.errorLight,
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
              color: AppColors.errorLight,
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
              color: AppColors.success,
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
                        _buildBehaviorsList(),
                      ],
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

  Widget _buildHeader() {
    // Parse background color
    Color bgColor = AppColors.secondary;
    if (_child != null) {
      try {
        bgColor = Color(
          int.parse(_child!.backgroundColor.replaceAll('#', '0xFF')),
        );
      } catch (e) {
        // Use default if parsing fails
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          // Child Avatar
          if (_child != null) ...[
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: bgColor.withValues(alpha: 0.2),
                  backgroundImage:
                      _child!.imageUrl != null && _child!.imageUrl!.isNotEmpty
                      ? NetworkImage(_child!.imageUrl!)
                      : null,
                  child: _child!.imageUrl == null || _child!.imageUrl!.isEmpty
                      ? Text(
                          _child!.firstName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: bgColor,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_child!.levelIndex}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _child?.fullName ?? 'Child',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _child?.className ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: bgColor,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/xp.png',
                        width: 14,
                        height: 14,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.stars,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_child?.points ?? 0}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          InkWell(
            onTap: () {
              final monthStr = DateFormat('yyyy-MM').format(_focusedDay);
              context.push(
                '/parent/child-report/${widget.kidId}?month=$monthStr',
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/report.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.assessment,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.t('report'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
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
              _loadDayBehaviors();
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

  Widget _buildBehaviorsList() {
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
              onPressed: _loadDayBehaviors,
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
            Image.asset(
              'assets/images/box 1.png',
              width: 200,
              height: 200,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.inbox,
                size: 100,
                color: AppColors.textSecondary,
              ),
            ),
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
          child: _buildBehaviorCard(
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

  Widget _buildBehaviorCard({
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
