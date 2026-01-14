import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/custom_text_field_signup.dart';
import 'package:me_plus/presentation/widgets/phone_input_field.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/widgets/language_switcher_button.dart';
import 'package:me_plus/presentation/providers/google_signup_provider.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/google_signup_request.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

/// Screen for collecting additional information after Google Sign-In
class GoogleSignupDetailsScreen extends StatefulWidget {
  const GoogleSignupDetailsScreen({super.key});

  @override
  State<GoogleSignupDetailsScreen> createState() =>
      _GoogleSignupDetailsScreenState();
}

class _GoogleSignupDetailsScreenState extends State<GoogleSignupDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _selectedRole;

  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  final AuthService _authService = AuthService();

  final List<Map<String, String>> roleOptions = [
    {'id': 'Student', 'labelKey': 'student'},
    {'id': 'Parent', 'labelKey': 'parent'},
    {'id': 'Market', 'labelKey': 'market_owner'},
  ];

  @override
  void initState() {
    super.initState();

    // Check if we have Google auth data
    final googleProvider = context.read<GoogleSignupProvider>();
    if (!googleProvider.hasGoogleAuth) {
      // No Google auth data, redirect back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }

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
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String? _validatePassword(String? value) {
    final localizations = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return localizations.t('password_required');
    }
    if (value.length < 8) {
      return localizations.t('password_min_8_chars');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return localizations.t('password_uppercase');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return localizations.t('password_lowercase');
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return localizations.t('password_number');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final localizations = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return localizations.t('please_confirm_password');
    }
    if (value != _passwordController.text) {
      return localizations.t('passwords_do_not_match');
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final googleProvider = context.read<GoogleSignupProvider>();

      // Save additional info in provider
      googleProvider.setAdditionalInfo(
        birthDate: _dobController.text,
        role: _selectedRole!,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      // For Market Owner, just navigate to collect market details
      // Don't call googleSignup() yet - we need market name and address first
      if (_selectedRole == 'Market') {
        if (mounted) {
          setState(() => _isLoading = false);
          context.go('/signup/market-owner');
        }
        return;
      }

      // For Student and Parent, create signup request and call API
      final request = GoogleSignupRequest(
        accessToken: googleProvider.accessToken!,
        birthDate: _dobController.text,
        role: _selectedRole!,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      // Send to backend
      await _authService.googleSignup(request);

      if (mounted) {
        setState(() => _isLoading = false);

        // Navigate based on role
        if (_selectedRole == 'Student') {
          // For students, go to school selection
          context.go('/signup/student/school-selection');
        } else if (_selectedRole == 'Parent') {
          // For parents, go to children emails
          context.go('/signup/parent');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

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
    final googleProvider = context.watch<GoogleSignupProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background blur
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

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo and Language Switcher
                      FadeTransition(
                        opacity: _fadeAnimations[0],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/images/logo.svg',
                              width: 199,
                              height: 70,
                            ),
                            const LanguageSwitcherButton(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Header
                      FadeTransition(
                        opacity: _fadeAnimations[0],
                        child: Column(
                          children: [
                            GradientText(
                              AppLocalizations.of(
                                context,
                              )!.t('complete_signup'),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (googleProvider.email != null)
                              Text(
                                googleProvider.email!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Role Selection
                      FadeTransition(
                        opacity: _fadeAnimations[1],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.t('select_role'),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                letterSpacing: -0.24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceInput,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.divider,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: roleOptions.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final role = entry.value;
                                  final isLast =
                                      index == roleOptions.length - 1;

                                  return Column(
                                    children: [
                                      RadioListTile<String>(
                                        title: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.t(role['labelKey']!),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        value: role['id']!,
                                        // ignore: deprecated_member_use
                                        groupValue: _selectedRole,
                                        // ignore: deprecated_member_use
                                        onChanged: (value) {
                                          setState(() => _selectedRole = value);
                                        },
                                        activeColor: AppColors.primary,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                      ),
                                      if (!isLast)
                                        const Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: AppColors.divider,
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Birth Date
                      FadeTransition(
                        opacity: _fadeAnimations[1],
                        child: CustomTextField(
                          label: AppLocalizations.of(
                            context,
                          )!.t('date_of_birth'),
                          controller: _dobController,
                          hintText: 'YYYY-MM-DD',
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.t('please_select_date_of_birth');
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone Number
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: PhoneInputField(
                          label: AppLocalizations.of(
                            context,
                          )!.t('phone_number'),
                          controller: _phoneController,
                          onChanged: (phone) {},
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: CustomTextField(
                          label: AppLocalizations.of(context)!.t('password'),
                          controller: _passwordController,
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          validator: _validatePassword,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password
                      FadeTransition(
                        opacity: _fadeAnimations[2],
                        child: CustomTextField(
                          label: AppLocalizations.of(
                            context,
                          )!.t('confirm_password'),
                          controller: _confirmPasswordController,
                          hintText: '••••••••',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                          ),
                          validator: _validateConfirmPassword,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      FadeTransition(
                        opacity: _fadeAnimations[3],
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.t('continue'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
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
}
