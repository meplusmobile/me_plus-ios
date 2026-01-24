import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/parent/parent_bottom_nav_bar.dart';
import 'package:me_plus/presentation/providers/parent_profile_provider.dart';
import 'package:me_plus/presentation/providers/children_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/data/repositories/parent_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/child_model.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  List<Child> _waitingChildren = [];
  bool _isLoadingWaiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentProfileProvider>().loadProfile();
      context.read<ChildrenProvider>().loadChildren();
      _loadWaitingChildren();
    });
  }

  Future<void> _loadWaitingChildren() async {
    setState(() => _isLoadingWaiting = true);
    try {
      final waiting = await ParentRepository().getWaitingChildren();
      if (mounted) {
        setState(() {
          _waitingChildren = waiting;
          _isLoadingWaiting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWaiting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<ChildrenProvider>(
                builder: (context, childrenProvider, child) {
                  if (childrenProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (childrenProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            childrenProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ChildrenProvider>().loadChildren();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMyKidsHeader(),
                          const SizedBox(height: 16),
                          ...childrenProvider.children.map((child) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildKidCard(
                                child: child,
                                context: context,
                              ),
                            );
                          }),
                          if (childrenProvider.children.isEmpty)
                            _buildNoChildrenCard(),
                          const SizedBox(height: 24),
                          _buildWaitingApprovalSection(),
                        ],
                      ),
                    );
                  },
                ),
            ),
            const ParentBottomNavBar(selectedIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ParentProfileProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;
        final name = profile != null
            ? '${profile.firstName} ${profile.lastName}'
            : 'Loading...';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.t('welcome_back'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyKidsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/kids.png',
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.extension, color: Colors.orange),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.t('my_kids'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        /*         Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ), */
      ],
    );
  }

  Widget _buildKidCard({required child, required BuildContext context}) {
    // Parse background color
    Color bgColor = AppColors.secondary;
    try {
      bgColor = Color(int.parse(child.backgroundColor.replaceAll('#', '0xFF')));
    } catch (e) {
      // Use default if parsing fails
    }

    return InkWell(
      onTap: () {
        // Navigate to child activity calendar when card is tapped
        context.push('/parent/child-activity/${child.id}');
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${child.levelIndex}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.t('more_details'),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: bgColor.withValues(alpha: 0.2),
                backgroundImage:
                    child.imageUrl != null && child.imageUrl!.isNotEmpty
                    ? NetworkImage(child.imageUrl!)
                    : null,
                child: child.imageUrl == null || child.imageUrl!.isEmpty
                    ? Text(
                        child.firstName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: bgColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      child.className,
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
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.stars,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${child.points}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.t('last_activity'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<List<BehaviorDate>>(
                    future: ParentRepository().getLastWeekActivities(
                      schoolId: child.schoolId,
                      classId: child.classId,
                      childId: child.id.toString(),
                    ),
                    builder: (context, snapshot) {
                      final localeProvider = context.watch<LocaleProvider>();
                      final isArabic = localeProvider.isArabic;

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        final now = DateTime.now();
                        final days = [
                          'SUN',
                          'MON',
                          'TUE',
                          'WED',
                          'THU',
                          'FRI',
                          'SAT',
                        ];
                        final daysAr = [
                          'الأحد',
                          'الإثنين',
                          'الثلاثاء',
                          'الأربعاء',
                          'الخميس',
                          'الجمعة',
                          'السبت',
                        ];
                        return Row(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          children: List.generate(4, (index) {
                            // Show last 4 days before today
                            // For Arabic RTL: reverse so newest (day -1) appears on right
                            final dayOffset = isArabic
                                ? (index + 1)
                                : (4 - index);
                            final dayDate = now.subtract(
                              Duration(days: dayOffset),
                            );
                            final dayLabel = isArabic
                                ? daysAr[dayDate.weekday % 7]
                                : days[dayDate.weekday % 7];
                            return Padding(
                              padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
                              child: _buildActivityDay(
                                dayLabel,
                                Icons.remove,
                                AppColors.secondary,
                              ),
                            );
                          }),
                        );
                      }

                      // Get last 4 days (should be already filtered by API)
                      List<BehaviorDate> activities = snapshot.data!
                          .take(4)
                          .toList();

                      // Pad with empty days if less than 4
                      if (activities.length < 4) {
                        final now = DateTime.now();
                        final existingDates = activities
                            .map((a) => a.date)
                            .toSet();

                        // Fill missing days
                        for (int i = 4; i >= 1; i--) {
                          final dayDate = now.subtract(Duration(days: i));
                          final normalizedDate = DateTime(
                            dayDate.year,
                            dayDate.month,
                            dayDate.day,
                          );

                          if (!existingDates.any(
                            (d) =>
                                d.year == normalizedDate.year &&
                                d.month == normalizedDate.month &&
                                d.day == normalizedDate.day,
                          )) {
                            activities.add(
                              BehaviorDate(
                                date: normalizedDate,
                                behaviorStatus: 'NONE',
                                dayStatuses: ',',
                              ),
                            );
                          }
                        }

                        // Sort by date ascending (oldest first)
                        activities.sort((a, b) => a.date.compareTo(b.date));
                        activities = activities.take(4).toList();
                      }

                      // Don't reverse - just use textDirection to handle RTL layout
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: activities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final activity = entry.value;
                          final status = activity.behaviorStatus.toUpperCase();

                          // Get day label (SUN, MON, TUE, etc)
                          final days = [
                            'SUN',
                            'MON',
                            'TUE',
                            'WED',
                            'THU',
                            'FRI',
                            'SAT',
                          ];
                          final daysAr = [
                            'الأحد',
                            'الإثنين',
                            'الثلاثاء',
                            'الأربعاء',
                            'الخميس',
                            'الجمعة',
                            'السبت',
                          ];
                          final dayLabel = isArabic
                              ? daysAr[activity.date.weekday % 7]
                              : days[activity.date.weekday % 7];

                          IconData icon;
                          Color color;

                          switch (status) {
                            case 'POSITIVE':
                            case 'GOOD':
                              icon = Icons.thumb_up_alt_outlined;
                              color = Colors.lightGreen;
                              break;
                            case 'NEGATIVE':
                            case 'BAD':
                              icon = Icons.thumb_down_alt_outlined;
                              color = Colors.red;
                              break;
                            case 'MIX':
                            case 'MIXED':
                              icon = Icons.thumbs_up_down_outlined;
                              color = Colors.orange;
                              break;
                            case 'NONE':
                            default:
                              icon = Icons.remove;
                              color = AppColors.secondary;
                          }

                          return Padding(
                            padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
                            child: _buildActivityDay(dayLabel, icon, color),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildActivityDay(String dayLabel, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayLabel,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(child: Icon(icon, size: 16, color: color)),
        ),
      ],
    );
  }

  Widget _buildNoChildrenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.family_restroom,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.t('no_children_yet'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.t('add_children_to_track'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingApprovalSection() {
    if (_isLoadingWaiting) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_waitingChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.t('pending_approval'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._waitingChildren.map((child) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildWaitingChildCard(child),
          );
        }),
      ],
    );
  }

  Widget _buildWaitingChildCard(Child child) {
    Color bgColor = AppColors.secondary;
    try {
      bgColor = Color(int.parse(child.backgroundColor.replaceAll('#', '0xFF')));
    } catch (e) {
      // Use default if parsing fails
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: bgColor.withValues(alpha: 0.2),
            backgroundImage:
                child.imageUrl != null && child.imageUrl!.isNotEmpty
                ? NetworkImage(child.imageUrl!)
                : null,
            child: child.imageUrl == null || child.imageUrl!.isEmpty
                ? Text(
                    child.firstName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bgColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.fullName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  child.email,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.t('still_waiting_for_approval'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
