import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/custom_text_field_signup.dart';
import 'package:me_plus/presentation/widgets/phone_input_field.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/widgets/language_switcher_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:me_plus/presentation/providers/signup_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: '');
  final _lastNameController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _phoneController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  final _confirmPasswordController = TextEditingController(text: '');
  final _dobController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  bool get _isFormValid {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _dobController.text.isNotEmpty;
  }

  String? _validatePassword(String? value) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return 'Password is required';

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
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return localizations.t('password_special_char');
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return 'Please confirm your password';

    if (value == null || value.isEmpty) {
      return localizations.t('please_confirm_password');
    }
    if (value != _passwordController.text) {
      return localizations.t('passwords_do_not_match');
    }
    return null;
  }

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

    // Removed listeners - validation is handled in form, not on every keystroke
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        _dobController.text = DateFormat('MM / dd / yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
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

            // Top left vector
            Positioned(
              top: 40,
              left: 12,
              child: FadeTransition(
                opacity: _fadeAnimations[3],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(_fadeAnimations[3]),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 199,
                    height: 70,
                  ),
                ),
              ),
            ),

            // Language switcher
            Positioned(
              top: 40,
              right: 12,
              child: FadeTransition(
                opacity: _fadeAnimations[3],
                child: const LanguageSwitcherButton(),
              ),
            ),

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 158),

                    // Header
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
                            return Column(
                              children: [
                                GradientText(
                                  localizations.t('sign_up'),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      localizations.t('already_have_account'),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.disabled,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/login');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        localizations.t('sign_in'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form fields
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
                            return Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextField(
                                          label: localizations.t(
                                            'first_name_label',
                                          ),
                                          controller: _firstNameController,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: CustomTextField(
                                          label: localizations.t(
                                            'last_name_label',
                                          ),
                                          controller: _lastNameController,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: localizations.t('email'),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),

                                  const SizedBox(height: 16),

                                  PhoneInputField(
                                    label: localizations.t(
                                      'phone_number_label',
                                    ),
                                    controller: _phoneController,
                                  ),

                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: localizations.t('set_password'),
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    validator: _validatePassword,
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

                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: localizations.t('confirm_password'),
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    validator: _validateConfirmPassword,
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

                                  const SizedBox(height: 16),

                                  CustomTextField(
                                    label: localizations.t(
                                      'date_of_birth_label',
                                    ),
                                    controller: _dobController,
                                    hintText: 'MM / DD / YYYY',
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_today,
                                        color: AppColors.textPrimary,
                                        size: 16,
                                      ),
                                      onPressed: () => _selectDate(context),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Next Button
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
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: !_isFormValid
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          // Validate all fields are filled
                                          if (_firstNameController
                                                  .text
                                                  .isEmpty ||
                                              _lastNameController
                                                  .text
                                                  .isEmpty ||
                                              _emailController.text.isEmpty ||
                                              _phoneController.text.isEmpty ||
                                              _passwordController
                                                  .text
                                                  .isEmpty ||
                                              _confirmPasswordController
                                                  .text
                                                  .isEmpty ||
                                              _dobController.text.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  localizations.t(
                                                    'please_fill_all_fields',
                                                  ),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          // Validate passwords match
                                          if (_passwordController.text !=
                                              _confirmPasswordController.text) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  localizations.t(
                                                    'passwords_do_not_match',
                                                  ),
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          // Parse date from MM / DD / YYYY to yyyy-MM-dd format
                                          final dobParts = _dobController.text
                                              .split(' / ');
                                          final birthdate =
                                              '${dobParts[2]}-${dobParts[0].padLeft(2, '0')}-${dobParts[1].padLeft(2, '0')}';

                                          // Save to provider
                                          final signupData = context
                                              .read<SignupData>();
                                          signupData.setBasicInfo(
                                            firstName:
                                                _firstNameController.text,
                                            lastName: _lastNameController.text,
                                            email: _emailController.text,
                                            phoneNumber: _phoneController.text,
                                            password: _passwordController.text,
                                            birthdate: birthdate,
                                          );

                                          // Navigate to role selection
                                          context.go('/role-selection');
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  localizations.t('next'),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
          ],
        ),
      ),
    );
  }
}
