import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/student/bottom_nav_bar.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _loadLanguage() async {
    final localeProvider = context.read<LocaleProvider>();
    setState(() {
      _selectedLanguage = localeProvider.isArabic ? 'Arabic' : 'English';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final localeProvider = context.read<LocaleProvider>();
    await localeProvider.setLocale(language == 'Arabic' ? 'ar' : 'en');
    setState(() {
      _selectedLanguage = language;
    });
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
                        _buildProfileCard(),
                        const SizedBox(height: 24),
                        _buildMenuItems(context),
                      ],
                    ),
                  ),
                ),
              ),
              const BottomNavBar(selectedIndex: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 24, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text(
              l10n.t('my_profile'),
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
    );
  }

  Widget _buildProfileCard() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final profile = profileProvider.profile;
        if (profile == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryVeryLight,
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
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child:
                          profile.profileImageUrl != null &&
                              profile.profileImageUrl!.isNotEmpty
                          ? Image.network(
                              _getImageUrl(profile.profileImageUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.secondary,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.secondary,
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email ?? 'Masa.zayn@petra.africa',
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

  String _getImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    const baseUrl = 'https://meplus2.blob.core.windows.net/images';
    String cleanPath = url
        .replaceAll('/uploads/images/', '')
        .replaceAll('//', '/');
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return '$baseUrl/$cleanPath';
  }

  Widget _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: l10n.t('my_account'),
          subtitle: l10n.t('make_changes_to_your_account'),
          onTap: () {
            context.go('/student/account');
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.shopping_bag_outlined,
          title: l10n.t('my_purchases'),
          subtitle: l10n.t('check_your_previous_prizes'),
          onTap: () {
            context.go('/student/purchases');
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.warning_amber_outlined,
          title: l10n.t('report_a_missing_reward'),
          subtitle: l10n.t('report_missing_well_handle_it'),
          onTap: () {
            context.go('/student/report-missing');
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.language,
          title: l10n.t('language'),
          subtitle: l10n.t('select_your_language'),
          onTap: () {
            _showLanguageDialog(context);
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.bug_report_outlined,
          iconColor: Colors.purple,
          title: 'API Debug',
          subtitle: 'Test API connections',
          onTap: () {
            context.go('/debug/api');
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.logout,
          iconColor: AppColors.errorLight,
          title: l10n.t('logout'),
          subtitle: '',
          onTap: () async {
            // Clear profile and auth data
            await context.read<ProfileProvider>().clearProfile();
            await AuthService().logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.secondary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.secondary,
                size: 24,
              ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      l10n.t('language'),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.disabled,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.t('search_language'),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    _saveLanguage('English');
                    Navigator.pop(context);
                  },
                  child: _buildLanguageOption(
                    l10n.t('english'),
                    'assets/images/us.png',
                    _selectedLanguage == 'English',
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    _saveLanguage('Arabic');
                    Navigator.pop(context);
                  },
                  child: _buildLanguageOption(
                    l10n.t('arabic'),
                    'assets/images/ps.png',
                    _selectedLanguage == 'Arabic',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String language,
    String flagPath,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                flagPath,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            language,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
        ],
      ),
    );
  }
}
