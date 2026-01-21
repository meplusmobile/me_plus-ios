import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/custom_text_field_signin.dart';
import 'package:me_plus/presentation/widgets/gradient_button.dart';
import 'package:me_plus/presentation/widgets/gradient_text.dart';
import 'package:me_plus/presentation/widgets/language_switcher_button.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/data/services/token_storage_service.dart';
import 'package:me_plus/data/models/login_request.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    // Defer SharedPreferences call until after first frame (iOS requirement)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedCredentials();
    });
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.6 + (index * 0.1),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadSavedCredentials() async {
    final tokenStorage = TokenStorageService();
    final rememberMe = await tokenStorage.getRememberMe();
    
    if (rememberMe) {
      final email = await tokenStorage.getSavedEmail();
      final password = await tokenStorage.getSavedPassword();
      
      if (email != null && password != null) {
        setState(() {
          _rememberMe = true;
          _emailController.text = email;
          _passwordController.text = password;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.t('please_enter_email_and_password'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = LoginRequest(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final response = await _authService.login(request);

      if (!mounted) return;

      // Save Remember Me credentials
      final tokenStorage = TokenStorageService();
      await tokenStorage.saveRememberMe(
        rememberMe: _rememberMe,
        email: _rememberMe ? _emailController.text : null,
        password: _rememberMe ? _passwordController.text : null,
      );

      if (!mounted) return;

      if (response.role == 'Student') {
        if (response.schoolId == null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.t('pending_approval'),
                    style: const TextStyle(fontFamily: 'Poppins', 
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.t('request_waiting_for_school_approval'),
                    style: const TextStyle(fontFamily: 'Poppins', 
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.t('notify_when_approved'),
                    style: const TextStyle(fontFamily: 'Poppins', 
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog only
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.t('ok'),
                    style: const TextStyle(fontFamily: 'Poppins', 
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          final profileProvider = context.read<ProfileProvider>();
          profileProvider.loadProfile(forceRefresh: true).catchError((error) {
            // Failed to load profile
          });

          context.go('/student/home');
        }
      } else if (response.role == 'Market') {
        context.go('/market-owner/home');
      } else if (response.role == 'Parent') {
        context.go('/parent/home');
      } else {
        // For other roles, navigate to a default home or placeholder
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.t('login_failed'),
                  style: const TextStyle(fontFamily: 'Poppins', 
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getErrorMessage(e.toString()),
                style: const TextStyle(fontFamily: 'Poppins', 
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.t('ok'),
                style: const TextStyle(fontFamily: 'Poppins', 
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    final cleanError = error.replaceAll('Exception: ', '').toLowerCase();
    
    if (cleanError.contains('invalid') && (cleanError.contains('credential') || cleanError.contains('email') || cleanError.contains('password'))) {
      return AppLocalizations.of(context)!.t('invalid_credentials_message');
    } else if (cleanError.contains('network') || cleanError.contains('connection')) {
      return AppLocalizations.of(context)!.t('network_error_message');
    } else if (cleanError.contains('timeout')) {
      return AppLocalizations.of(context)!.t('timeout_error_message');
    } else if (cleanError.contains('not found') || cleanError.contains('user not found')) {
      return AppLocalizations.of(context)!.t('user_not_found_message');
    } else {
      return error.replaceAll('Exception: ', '');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              bottom: -80,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/bottombackgroundloginpage.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    FadeTransition(
                      opacity: _fadeAnimations[3],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[3]),
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
                    ),

                    const SizedBox(height: 51),

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
                                  localizations.t('sign_in'),
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
                                    letterSpacing: -0.64,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  localizations.t(
                                    'enter_email_password_to_sign_in',
                                  ),
                                  style: const TextStyle(fontFamily: 'Poppins', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email field
                                Text(
                                  localizations.t('email'),
                                  style: const TextStyle(fontFamily: 'Poppins', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    letterSpacing: -0.24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                CustomTextField(
                                  controller: _emailController,
                                  hintText: '',
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 16),

                                // Password field
                                Text(
                                  localizations.t('password'),
                                  style: const TextStyle(fontFamily: 'Poppins', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    letterSpacing: -0.24,
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

                                const SizedBox(height: 16),

                                // Remember me and Forgot password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value ?? false;
                                              });
                                            },
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          localizations.t('remember_me'),
                                          style: const TextStyle(fontFamily: 'Poppins', 
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.push('/forgot-password');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        localizations.t('forgot_password'),
                                        style: const TextStyle(fontFamily: 'Poppins', 
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

                    // Sign in button and social login
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
                            return Column(
                              children: [
                                GradientButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  text: localizations.t('sign_in'),
                                  enabled: !_isLoading,
                                  isLoading: _isLoading,
                                ),

                                const SizedBox(height: 32),

                                // Divider with text
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        localizations.t('or_sign_in_with'),
                                        style: const TextStyle(fontFamily: 'Poppins', 
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          letterSpacing: -0.12,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // DISABLED: Google sign in button - DISABLED
                                // Container(
                                //   height: 48,
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     borderRadius: BorderRadius.circular(10),
                                //     border: Border.all(
                                //       color: AppColors.secondaryLight,
                                //     ),
                                //     boxShadow: [
                                //       BoxShadow(
                                //         color: AppColors.secondaryLight
                                //             .withValues(alpha: 0.6),
                                //         blurRadius: 6,
                                //         offset: const Offset(0, -3),
                                //       ),
                                //     ],
                                //   ),
                                //   child: Material(
                                //     color: Colors.transparent,
                                //     child: InkWell(
                                //       onTap: _isGoogleLoading || _isLoading
                                //           ? null
                                //           : _handleGoogleSignIn,
                                //       borderRadius: BorderRadius.circular(10),
                                //       child: Center(
                                //         child: _isGoogleLoading
                                //             ? const SizedBox(
                                //                 width: 18,
                                //                 height: 18,
                                //                 child: CircularProgressIndicator(
                                //                   strokeWidth: 2,
                                //                   valueColor:
                                //                       AlwaysStoppedAnimation<
                                //                         Color
                                //                       >(AppColors.primary),
                                //                 ),
                                //               )
                                //             : SvgPicture.asset(
                                //                 'assets/images/Google__G__logo.svg',
                                //                 width: 18,
                                //                 height: 18,
                                //               ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(height: 24),

                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      localizations.t('dont_have_account'),
                                      style: const TextStyle(fontFamily: 'Inter', 
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.disabled,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/signup');
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        localizations.t('sign_up'),
                                        style: const TextStyle(fontFamily: 'Poppins', 
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
