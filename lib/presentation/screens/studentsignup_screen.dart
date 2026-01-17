import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/widgets/gradient_button.dart';
import 'package:me_plus/presentation/providers/signup_provider.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/signup_request.dart';

class StudentScreenSignUp extends StatefulWidget {
  const StudentScreenSignUp({super.key});

  @override
  State<StudentScreenSignUp> createState() => _StudentScreenSignUpState();
}

class _StudentScreenSignUpState extends State<StudentScreenSignUp> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  bool get _isFormValid => !_isLoading;

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final signupData = context.read<SignupData>();

      // Create signup request without school/class (will be selected after)
      final request = SignupRequest(
        firstName: signupData.firstName!,
        lastName: signupData.lastName!,
        birthdate: signupData.birthdate!,
        role: signupData.role!,
        email: signupData.email!,
        phoneNumber: signupData.phoneNumber!,
        password: signupData.password!,
      );

      await _authService.signup(request);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Token is already saved in signup response automatically
        context.go('/signup/student/school-selection');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
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

            Positioned(
              top: 40,
              left: 12,
              child: IgnorePointer(
                child: SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 199,
                  height: 70,
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 158),

                    Column(
                      children: [
                        const GradientText(
                          'Sign Up',
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.64,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete your registration. You will select your school and class in the next step.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'Inter', 
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.disabled,
                            letterSpacing: -0.12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Create Account Button
                    GradientButton(
                      text: _isLoading
                          ? 'Creating Account...'
                          : 'Create Account',
                      onPressed: _handleSignup,
                      enabled: _isFormValid,
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
