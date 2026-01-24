import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/student/bottom_nav_bar.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';

class Top10Screen extends StatefulWidget {
  const Top10Screen({super.key});

  @override
  State<Top10Screen> createState() => _Top10ScreenState();
}

class _Top10ScreenState extends State<Top10Screen> {
  final StudentRepository _repository = StudentRepository();
  List<HonorListStudent> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHonorList();
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    // Remove /uploads/images/ if it exists at the start
    final cleanUrl = imageUrl.replaceFirst(RegExp(r'^\/uploads\/images\/'), '');
    // Remove leading slash if exists
    final finalUrl = cleanUrl.startsWith('/')
        ? cleanUrl.substring(1)
        : cleanUrl;
    return 'https://meplus2.blob.core.windows.net/images/$finalUrl';
  }

  Future<void> _loadHonorList() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final students = await _repository.getHonorList();

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _error != null
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
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadHonorList,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildPodium(),
                            const SizedBox(height: 24),
                            _buildRankingList(),
                          ],
                        ),
                      ),
              ),
              const BottomNavBar(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/student/home'),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.t('top_10'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    if (_students.length < 3) {
      return const SizedBox.shrink();
    }

    final first = _students[0];
    final second = _students[1];
    final third = _students[2];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.background, // Light beige background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.t('top_3'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryDark,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 155,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Base platform line
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF455A64),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Black bar for 1st place (positioned above the red block)
                Positioned(
                  bottom: 106, // 6 (base) + 100 (height)
                  child: Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.textDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Blocks Row (Centered and tightly packed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd Place
                      _buildPodiumBlock(
                        student: second,
                        rank: 2,
                        color: const Color(0xFFFDE047), // Yellow
                        height: 70,
                        width: 95,
                      ),
                      // 1st Place
                      _buildPodiumBlock(
                        student: first,
                        rank: 1,
                        color: const Color(0xFFEF4444), // Red
                        height: 100,
                        width: 105,
                        isFirst: false, // Remove the bar from inside the block
                      ),
                      // 3rd Place
                      _buildPodiumBlock(
                        student: third,
                        rank: 3,
                        color: const Color(0xFF60A5FA), // Blue
                        height: 50,
                        width: 95,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumBlock({
    required HonorListStudent student,
    required int rank,
    required Color color,
    required double height,
    required double width,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) ...[
          const Icon(
            Icons.emoji_events,
            color: AppColors.warningGold,
            size: 24,
          ),
          const SizedBox(height: 2),
        ],
        // Name
        SizedBox(
          width: width, // Constrain to block width to prevent gaps
          child: Text(
            student.name,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isFirst ? const Color(0xFFF59E0B) : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        // Block
        SizedBox(
          width: width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Main Block
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList() {
    // Show ALL students in the list, starting from Rank 1
    final allStudents = _students;

    if (allStudents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.t('name'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.t('score'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          ...allStudents.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            final rank = index + 1;

            return _buildRankingItem(
              rank: rank,
              name: student.name,
              score: student.points,
              avatar: _getImageUrl(student.imageUrl),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required String name,
    required int score,
    required String avatar,
  }) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    Color cardColor;
    Color bubbleColor; // For the subtle circles

    switch (rank) {
      case 1:
        cardColor = AppColors.error; // Red
        bubbleColor = Colors.white.withValues(alpha: 0.1);
        break;
      case 2:
        cardColor = const Color(0xFFFBC02D); // Yellow
        bubbleColor = Colors.white.withValues(alpha: 0.2);
        break;
      case 3:
        cardColor = const Color(0xFF4FC3F7); // Blue
        bubbleColor = Colors.white.withValues(alpha: 0.1);
        break;
      default:
        cardColor = const Color(0xFFB0BEC5); // Grey
        bubbleColor = Colors.white.withValues(alpha: 0.2);
        break;
    }

    // All text is white in the design image
    const textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name Card
          Expanded(
            child: SizedBox(
              height: 76, // Matched with score bubble height
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Background
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Decorative Circles (Bubbles)
                          Positioned(
                            top: -10,
                            right: 40,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: bubbleColor,
                            ),
                          ),
                          Positioned(
                            bottom: -15,
                            right: 80,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: bubbleColor,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: -10,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: bubbleColor,
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Rank
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    rank.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Avatar
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      avatar,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Level Badge (Top Right/Left based on locale hanging) - Using 5image.png
                  Positioned(
                    top: -1,
                    right: isArabic ? null : 20,
                    left: isArabic ? 20 : null,
                    child: Image.asset(
                      'assets/images/5image.png',
                      width: 24,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Score Bubble - Same height as name card
          Container(
            width: 80,
            height: 76, // Matched with name card height
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              score.toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
