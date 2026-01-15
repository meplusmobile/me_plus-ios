import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

enum UserRole { student, parent, marketOwner }

class OnboardingScreen extends StatefulWidget {
  final UserRole role;

  const OnboardingScreen({super.key, required this.role});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<OnboardingPage> _buildPages(BuildContext context, UserRole role) {
    final localizations = AppLocalizations.of(context)!;

    switch (role) {
      case UserRole.student:
        return [
          OnboardingPage(
            image: 'assets/images/Winners-amico 1.png',
            title: localizations.t('track_behavior_easily'),
            description: localizations.t('track_behavior_desc'),
            buttonText: '',
          ),
          OnboardingPage(
            image: 'assets/images/Celebration-amico 1.png',
            title: localizations.t('earn_points_rewards'),
            description: localizations.t('earn_points_desc'),
            buttonText: localizations.t('go'),
          ),
        ];
      case UserRole.parent:
        return [
          OnboardingPage(
            image: 'assets/images/Child.png',
            title: localizations.t('stay_connected'),
            description: localizations.t('stay_connected_desc'),
            buttonText: '',
          ),
          OnboardingPage(
            image: 'assets/images/Cheer up-amico 1.png',
            title: localizations.t('support_and_encourage'),
            description: localizations.t('support_encourage_desc'),
            buttonText: '',
          ),
          OnboardingPage(
            image: 'assets/images/Feedback-cuate 1.png',
            title: localizations.t('track_their_progress'),
            description: localizations.t('track_progress_desc'),
            buttonText: localizations.t('go'),
          ),
        ];
      case UserRole.marketOwner:
        return [
          OnboardingPage(
            image: 'assets/images/leadership-amico 1.png',
            title: localizations.t('be_part_motivation'),
            description: localizations.t('be_part_motivation_desc'),
            buttonText: '',
          ),
          OnboardingPage(
            image: 'assets/images/Accept request-amico 1.png',
            title: localizations.t('manage_reward_requests'),
            description: localizations.t('manage_reward_desc'),
            buttonText: '',
          ),
          OnboardingPage(
            image: 'assets/images/Education-pana 1.png',
            title: localizations.t('grow_your_impact'),
            description: localizations.t('grow_impact_desc'),
            buttonText: localizations.t('go'),
          ),
        ];
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _getPageCount() - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  int _getPageCount() {
    switch (widget.role) {
      case UserRole.student:
        return 2;
      case UserRole.parent:
        return 3;
      case UserRole.marketOwner:
        return 3;
    }
  }

  void _completeOnboarding() {
    context.go('/login');
  }

  void _skip() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 16,
              right: 24,
              child: Builder(
                builder: (context) {
                  final localizations = AppLocalizations.of(context)!;
                  return TextButton(
                    onPressed: _skip,
                    child: Text(
                      localizations.t('skip'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 150,
                  height: 50,
                ),
              ),
            ),

            // PageView
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Builder(
                builder: (context) {
                  final pages = _buildPages(context, widget.role);
                  return PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(pages[index]);
                    },
                  );
                },
              ),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Builder(
                builder: (context) {
                  final pages = _buildPages(context, widget.role);
                  return Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => _buildDot(index, pages.length),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Navigation button
                      if (pages[_currentPage].buttonText.isNotEmpty)
                        _buildNavigationButton(pages[_currentPage].buttonText)
                      else
                        _buildArrowButton(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Image
          Image.asset(page.image, height: 280, fit: BoxFit.contain),
          const SizedBox(height: 40),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, int pagesLength) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.textSecondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildArrowButton() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildNavigationButton(String text) {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  final String buttonText;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}
