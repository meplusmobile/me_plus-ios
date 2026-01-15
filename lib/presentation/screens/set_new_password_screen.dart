import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/custom_text_field_signin.dart';
import 'package:me_plus/presentation/widgets/gradient_button.dart';
import 'package:me_plus/presentation/widgets/language_switcher_button.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final Map<String, String>? resetData;

  const SetNewPasswordScreen({super.key, this.resetData});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            ((index * 0.2) + 0.6).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    final localizations = AppLocalizations.of(context)!;

    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.t('please_fill_in_all_fields')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.t('passwords_do_not_match_error')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final resetData = widget.resetData;
    if (resetData == null ||
        resetData['email'] == null ||
        resetData['code'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.t('invalid_reset_data')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {});

    try {
      await _authService.resetPassword(
        resetData['email']!,
        resetData['code']!,
        _passwordController.text,
      );

      if (mounted) {
        setState(() {});

        context.go('/password-success');
      }
    } catch (e) {
      if (mounted) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/bottombackgroundloginpage.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // Main content with scrolling
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80), // Increased space for logo area
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context.go(
                            '/verify-code',
                            extra: widget.resetData?['email'] ?? '',
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.centerLeft,
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: _fadeAnimations[0],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[0]),
                        child: Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context)!;
                            return Text(
                              localizations.t('set_a_new_password'),
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.64,
                                height: 1.3,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: _fadeAnimations[0],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[0]),
                        child: Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context)!;
                            return Text(
                              localizations.t('create_new_password_security'),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.disabled,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Set Password field
                    FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[1]),
                        child: Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context)!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.t('set_password'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.disabled,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CustomTextField(
                                  controller: _passwordController,
                                  hintText: '',
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textPrimary,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confirm Password field
                    FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[1]),
                        child: Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context)!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.t('confirm_password'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.disabled,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CustomTextField(
                                  controller: _confirmPasswordController,
                                  hintText: '',
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.textPrimary,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Update Password Button
                    FadeTransition(
                      opacity: _fadeAnimations[2],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[2]),
                        child: Builder(
                          builder: (context) {
                            final localizations = AppLocalizations.of(context)!;
                            return ValueListenableBuilder(
                              valueListenable: _passwordController,
                              builder: (context, value, child) {
                                return ValueListenableBuilder(
                                  valueListenable: _confirmPasswordController,
                                  builder: (context, value2, child) {
                                    final isEnabled =
                                        _passwordController.text.isNotEmpty &&
                                        _confirmPasswordController
                                            .text
                                            .isNotEmpty;
                                    return GradientButton(
                                      text: localizations.t('update_password'),
                                      onPressed: _handleUpdatePassword,
                                      enabled: isEnabled,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),

                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: 120,
                        height: 40,
                      ),
                    ),

                    // Language switcher
                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: const LanguageSwitcherButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
