import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/role_button.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/providers/signup_provider.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/models/signup_request.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;

  final List<Map<String, String>> roleOptions = [
    {'id': 'student', 'labelKey': 'student'},
    {'id': 'parent', 'labelKey': 'parent'},
    {'id': 'market-owner', 'labelKey': 'market_owner'},
  ];

  String? selectedRole;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimations = List.generate(
      3,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
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
              child: FadeTransition(
                opacity: _fadeAnimations[2],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(_fadeAnimations[2]),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 158),

                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildRoleSelection(),
                    const SizedBox(height: 48),
                    _buildNextButton(),
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
    return FadeTransition(
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
                  localizations.t('choose_role'),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.64,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.t('select_role_to_continue'),
                  style: const TextStyle(fontFamily: 'Inter', 
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: -0.12,
                    height: 1.4,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return FadeTransition(
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
                  localizations.t('select_role_to_continue'),
                  style: const TextStyle(fontFamily: 'Poppins', 
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                ...roleOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final role = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < roleOptions.length - 1 ? 16 : 0,
                    ),
                    child: RoleButton(
                      label: localizations.t(role['labelKey']!),
                      isSelected: selectedRole == role['id'],
                      onTap: () {
                        setState(() {
                          selectedRole = role['id'];
                        });
                      },
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return FadeTransition(
      opacity: _fadeAnimations[1],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_fadeAnimations[1]),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_isLoading || selectedRole == null)
                ? null
                : () async {
                    final signupData = context.read<SignupData>();

                    // Map role ID to role name for API
                    String roleName;
                    switch (selectedRole) {
                      case 'student':
                        roleName = 'Student';
                        signupData.setRole(roleName);

                        // For students, perform signup in background and go directly to school selection
                        setState(() => _isLoading = true);

                        try {
                          final request = SignupRequest(
                            firstName: signupData.firstName!,
                            lastName: signupData.lastName!,
                            birthdate: signupData.birthdate!,
                            role: roleName,
                            email: signupData.email!,
                            phoneNumber: signupData.phoneNumber!,
                            password: signupData.password!,
                          );

                          await _authService.signup(request);

                          if (mounted) {
                            setState(() => _isLoading = false);
                            context.go('/signup/student/school-selection');
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                        break;

                      case 'parent':
                        roleName = 'Parent';
                        signupData.setRole(roleName);
                        context.go('/signup/parent');
                        break;

                      case 'market-owner':
                        roleName = 'Market';
                        signupData.setRole(roleName);
                        context.go('/signup/market-owner');
                        break;
                    }
                  },
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      final localizations = AppLocalizations.of(context)!;
                      return Text(
                        localizations.t('next'),
                        style: const TextStyle(fontFamily: 'Poppins', 
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
