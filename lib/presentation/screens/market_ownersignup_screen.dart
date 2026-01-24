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
import 'package:me_plus/presentation/providers/google_signup_provider.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/signup_request.dart';
import 'package:me_plus/data/models/google_signup_request.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class MarketOwnerScreenSignUp extends StatefulWidget {
  const MarketOwnerScreenSignUp({super.key});

  @override
  State<MarketOwnerScreenSignUp> createState() =>
      _MarketOwnerScreenSignUpState();
}

class _MarketOwnerScreenSignUpState extends State<MarketOwnerScreenSignUp>
    with SingleTickerProviderStateMixin {
  final TextEditingController _marketNameController = TextEditingController();
  final TextEditingController _marketAddressController =
      TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  bool get _isFormValid =>
      _marketNameController.text.isNotEmpty &&
      _marketAddressController.text.isNotEmpty &&
      !_isLoading;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();

    // Add listeners to rebuild when text changes
    _marketNameController.addListener(() => setState(() {}));
    _marketAddressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _marketNameController.dispose();
    _marketAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (_marketNameController.text.isEmpty ||
        _marketAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.t('please_fill_all_fields'),
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
      final googleProvider = context.read<GoogleSignupProvider>();

      // Check if this is Google signup
      final isGoogleSignup =
          googleProvider.hasGoogleAuth && googleProvider.hasBasicInfo;

      if (isGoogleSignup) {
        // Google signup flow - save market info in provider and call googleSignup
        googleProvider.setMarketOwnerInfo(
          marketName: _marketNameController.text,
          marketAddress: _marketAddressController.text,
        );

        // Combine First Name and Market Name for Google Signup
        final encodedFirstName =
            '${googleProvider.firstName}||${_marketNameController.text}';

        // Create Google signup request with all required data
        final request = GoogleSignupRequest(
          accessToken: googleProvider.accessToken!,
          birthDate: googleProvider.birthDate!,
          role: googleProvider.role!,
          phoneNumber: googleProvider.phoneNumber!,
          password: googleProvider.password!,
          marketName: _marketNameController.text,
          address: _marketAddressController.text,
          firstName: encodedFirstName,
        );

        // Call Google signup API
        final response = await _authService.googleSignup(request);

        // WORKAROUND: Explicitly update profile with encoded first name
        // The backend might ignore firstName in googleSignup, so we update it manually
        try {
          await _authService.updateProfile({'FirstName': encodedFirstName});
        } catch (e) {
          // Continue anyway, as signup was successful
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show verification overlay
          VerificationOverlay.show(
            context,
            onComplete: () {
              // Navigate based on isFirstTimeUser
              if (response.isFirstTimeUser) {
                context.push('/onboarding/market-owner');
              } else {
                context.push('/');
              }
            },
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        // Regular signup flow
        // Save market owner specific info
        signupData.setMarketOwnerInfo(
          marketName: _marketNameController.text,
          marketAddress: _marketAddressController.text,
        );

        // Combine First Name and Market Name
        final combinedFirstName =
            '${signupData.firstName}||${signupData.marketName}';

        // Create signup request
        final request = SignupRequest(
          firstName: combinedFirstName,
          lastName: signupData.lastName!,
          birthdate: signupData.birthdate!,
          role: signupData.role!,
          email: signupData.email!,
          phoneNumber: signupData.phoneNumber!,
          password: signupData.password!,
          address: signupData.marketAddress!,
        );

        // Call API
        final response = await _authService.signup(request);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show verification overlay
          VerificationOverlay.show(
            context,
            onComplete: () {
              // Navigate based on isFirstTimeUser
              if (response.isFirstTimeUser) {
                context.push('/onboarding/market-owner');
              } else {
                context.push('/');
              }
            },
            duration: const Duration(seconds: 3),
          );
        }
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 158),

                    // Header
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildHeader(),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildForm(),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Create Account Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildCreateAccountButton(),
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
          localizations.t('help_students_find_store'),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.disabled,
            height: 1.4,
            letterSpacing: -0.12,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        CustomTextField(
          label: localizations.t('market_name'),
          controller: _marketNameController,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: localizations.t('market_address'),
          controller: _marketAddressController,
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    final localizations = AppLocalizations.of(context)!;
    return GradientButton(
      text: _isLoading
          ? localizations.t('creating_account')
          : localizations.t('create_account'),
      onPressed: _handleCreateAccount,
      enabled: _isFormValid,
    );
  }
}
