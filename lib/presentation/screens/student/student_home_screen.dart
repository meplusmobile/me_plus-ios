import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/student/bottom_nav_bar.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/core/services/prefetch_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.loadProfile();

      // Start background prefetch for instant page loading
      PrefetchService().startPrefetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0,
            ),
            body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.secondary, AppColors.background],
                    stops: [0.0, 0.35],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: profileProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : profileProvider.error != null
                          ? Center(
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
                                    AppLocalizations.of(
                                      context,
                                    )!.t('error_loading_data'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    profileProvider.error!,
                                    style: const TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => profileProvider
                                        .loadProfile(forceRefresh: true),
                                    child: Text(
                                      AppLocalizations.of(context)!.t('retry'),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Column(
                                    children: [
                                      _buildHeader(profileProvider),
                                      const SizedBox(height: 16),
                                      _buildMainContent(),
                                    ],
                                  );
                                },
                              ),
                            ),
                    ),
                    const BottomNavBar(selectedIndex: 2),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProfileProvider profileProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.t('welcome_back')} ',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                profileProvider.studentName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Image(
                  image: AssetImage('assets/images/Group 481842.png'),
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 4),
                ShaderMask(
                  shaderCallback: (bounds) => const RadialGradient(
                    center: Alignment(0, -0.5),
                    radius: 1.0,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ).createShader(bounds),
                  child: Text(
                    '${profileProvider.credits}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Widget _buildMainContent() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildLevelCard(profileProvider),
              const SizedBox(height: 16),
              _buildLeaderboardCard(),
              const SizedBox(height: 16),
              _buildStoreSection(),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(ProfileProvider profileProvider) {
    final profile = profileProvider.profile;
    final levelName = profile?.levelName ?? 'Entry Level';
    final levelIndex = profile?.levelIndex ?? 1;
    final points = profile?.points ?? 0;
    final levelMaxPoints = profile?.levelMaxPoints ?? 500;
    final pointsToNext = levelMaxPoints - points;
    final progress = levelMaxPoints > 0 ? points / levelMaxPoints : 0.0;
    final levelImageUrl = profile?.levelImageUrl;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              levelImageUrl != null
                  ? Image.network(
                      'https://meplus2.blob.core.windows.net/images/$levelImageUrl',
                      width: 68,
                      height: 79,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 68,
                        height: 79,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Container(
                      width: 68,
                      height: 79,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pointsToNext > 0
                            ? '$pointsToNext ${AppLocalizations.of(context)!.t('expert_points_to_next_level')}'
                            : AppLocalizations.of(
                                context,
                              )!.t('level_completed'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress bar with level indicators
          Directionality(
            textDirection: Directionality.of(context),
            child: SizedBox(
              width: 294,
              height: 28,
              child: Stack(
                children: [
                  // Progress bar background (empty state)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // Progress bar filled portion
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    alignment: Directionality.of(context) == TextDirection.rtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Directionality.of(context) == TextDirection.rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          end: Directionality.of(context) == TextDirection.rtl
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          colors: const [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  // Level indicator (current)
                  Positioned(
                    left: Directionality.of(context) == TextDirection.rtl
                        ? null
                        : 0,
                    right: Directionality.of(context) == TextDirection.rtl
                        ? 0
                        : null,
                    top: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '$levelIndex',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Next level indicator
                  Positioned(
                    right: Directionality.of(context) == TextDirection.rtl
                        ? null
                        : 0,
                    left: Directionality.of(context) == TextDirection.rtl
                        ? 0
                        : null,
                    top: 2,
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${levelIndex + 1}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Progress text
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: '$points',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const TextSpan(
                            text: '/',
                            style: TextStyle(color: AppColors.background),
                          ),
                          TextSpan(
                            text: '$levelMaxPoints',
                            style: const TextStyle(color: AppColors.goldAccent),
                          ),
                        ],
                      ),
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

  Widget _buildLeaderboardCard() {
    return FutureBuilder<List<HonorListStudent>>(
      future: StudentRepository().getHonorList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length < 3) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final students = snapshot.data!;
        final first = students[0];
        final second = students[1];
        final third = students[2];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.15),
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
                  Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.t('top_3'),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) => TextButton(
                      onPressed: () {
                        context.push('/student/top10');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.t('see_top_10'),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Custom Podium
              LayoutBuilder(
                builder: (context, constraints) {
                  final podiumWidth = (constraints.maxWidth - 0) / 3;

                  return SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Base platform
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryDark,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Position 2 - Left (Yellow)
                        Positioned(
                          left: 0,
                          bottom: 5,
                          child: Column(
                            children: [
                              SizedBox(
                                width: podiumWidth,
                                child: Text(
                                  second.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 0),
                              Container(
                                width: podiumWidth,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDE047),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Position 1 - Center (Red)
                        Positioned(
                          bottom: 5,
                          child: Column(
                            children: [
                              SizedBox(
                                width: podiumWidth,
                                child: Text(
                                  first.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.errorCritical,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 0),
                              // Trophy top
                              Container(
                                width: podiumWidth + 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(2),
                                  ),
                                ),
                              ),
                              Container(
                                width: podiumWidth,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Position 3 - Right (Blue)
                        Positioned(
                          right: 0,
                          bottom: 5,
                          child: Column(
                            children: [
                              SizedBox(
                                width: podiumWidth,
                                child: Text(
                                  third.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 0),
                              Container(
                                width: podiumWidth,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF60A5FA),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildStoreSection() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    if (profileProvider.schoolId == null || profileProvider.classId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<StoreReward>>(
      future: StudentRepository().getStoreRewards(
        schoolId: profileProvider.schoolId!,
        classId: profileProvider.classId!,
        pageSize: 3,
        pageNumber: 1,
      ),
      builder: (context, snapshot) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/images/storeimage.png'),
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.t('store'),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () {
                        context.push('/student/store');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.t('see_more'),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final itemCount = snapshot.hasData && snapshot.data!.isNotEmpty
                    ? (snapshot.data!.length > 3 ? 3 : snapshot.data!.length)
                    : 3;

                // Calculate item width to fill available space
                const totalPadding = 16.0; // horizontal padding (8 * 2)
                final totalSpacing =
                    (itemCount - 1) * 12.0; // spacing between items
                final itemWidth =
                    (screenWidth - totalPadding - totalSpacing) / itemCount;

                return SizedBox(
                  height: 140,
                  child: snapshot.hasData && snapshot.data!.isNotEmpty
                      ? Row(
                          children: [
                            const SizedBox(width: 8),
                            ...List.generate(itemCount, (index) {
                              final reward = snapshot.data![index];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: index < itemCount - 1 ? 12 : 0,
                                  ),
                                  child: _buildStoreItem(
                                    reward.name,
                                    reward.price,
                                    reward.image,
                                    itemWidth,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStoreItem(
    String name,
    int price,
    String? imageUrl,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.card_giftcard,
                        size: 40,
                        color: AppColors.primary,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  )
                : const Icon(
                    Icons.card_giftcard,
                    size: 40,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Group 481842.png',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 3),
              Text(
                '$price',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

