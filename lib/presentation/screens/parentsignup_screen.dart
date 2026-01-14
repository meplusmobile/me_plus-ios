import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/custom_text_field_signup.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/widgets/gradient_button.dart';
import 'package:me_plus/presentation/widgets/verification_overlay.dart';
import 'package:me_plus/presentation/providers/signup_provider.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/signup_request.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class ParentScreenSignUp extends StatefulWidget {
  const ParentScreenSignUp({super.key});

  @override
  State<ParentScreenSignUp> createState() => _ParentScreenSignUpState();
}

class _ParentScreenSignUpState extends State<ParentScreenSignUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final List<String> childrenEmails = [];

  bool get _isFormValid => childrenEmails.isNotEmpty && !_isLoading;

  Future<void> _handleSignup() async {
    if (childrenEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.t('please_add_child_email'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final signupData = context.read<SignupData>();

      // Check if user already signed up (via Google)
      // If firstName is null, it means they came from Google signup
      final isGoogleSignup = signupData.firstName == null;

      if (!isGoogleSignup) {
        // Regular signup flow - create account first
        // Save parent specific info
        signupData.setParentInfo(childrenEmails: childrenEmails);

        // Create signup request (without childrenEmails in signup)
        final request = SignupRequest(
          firstName: signupData.firstName!,
          lastName: signupData.lastName!,
          birthdate: signupData.birthdate!,
          role: signupData.role!,
          email: signupData.email!,
          phoneNumber: signupData.phoneNumber!,
          password: signupData.password!,
        );

        // Call signup API
        await _authService.signup(request);
      } else {
        // Token already exists from Google OAuth
      }

      // Now submit parent request with children emails using the token
      await _authService.submitParentRequest(emails: childrenEmails);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show verification overlay
        VerificationOverlay.show(
          context,
          onComplete: () {
            // For Google signup, always go to onboarding (new users)
            if (isGoogleSignup) {
              context.go('/onboarding/parent');
            } else {
              // For regular signup, check isFirstTimeUser
              // Note: response might not be available for Google signup
              context.go('/onboarding/parent');
            }
          },
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background blur image
          Positioned(
            top: -180,
            left: 0,
            right: 0,
            child: Image.network(
              'https://c.animaapp.com/mhqrlq9bisClG6/img/blur.png',
              height: 430,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 430,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.blue.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom decoration
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

          // Top left logo (with IgnorePointer to allow clicks through)
          Positioned(
            top: 40,
            left: 12,
            child: IgnorePointer(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 199,
                    height: 70,
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 158),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildHeader(),
                      ),
                    ),
                    const SizedBox(height: 48),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildForm(),
                      ),
                    ),
                    const SizedBox(height: 48),

                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildVerifyButton(),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        GradientText(
          localizations.t('sign_up'),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.64,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.t('almost_there_add_child_email'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.disabled,
            letterSpacing: -0.12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: localizations.t('childs_email'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        // Display list of added child emails
        if (childrenEmails.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: childrenEmails.map((email) {
              return Chip(
                label: Text(email),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    childrenEmails.remove(email);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: InkWell(
            onTap: () {
              if (_emailController.text.isNotEmpty &&
                  _emailController.text.contains('@')) {
                setState(() {
                  childrenEmails.add(_emailController.text);
                  _emailController.clear();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(
                        context,
                      )!.t('please_enter_valid_email'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: const Icon(
              Icons.add_circle,
              size: 32,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    final localizations = AppLocalizations.of(context)!;
    return GradientButton(
      text: _isLoading
          ? localizations.t('creating_account')
          : localizations.t('verify'),
      onPressed: _handleSignup,
      enabled: _isFormValid,
    );
  }
}
