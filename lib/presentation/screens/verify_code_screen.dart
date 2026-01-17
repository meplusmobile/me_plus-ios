import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/presentation/widgets/gradient_button.dart';
import 'package:me_plus/presentation/widgets/language_switcher_button.dart';
import 'package:me_plus/data/services/auth_service.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

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

    // Add listeners to all controllers to trigger rebuild
    for (var controller in _controllers) {
      controller.addListener(() {
        setState(() {});
      });
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _handleVerifyCode() async {
    final code = _getCode();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.t('please_enter_complete_code'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {});

    try {
      await _authService.validateResetCode(widget.email, code);

      if (mounted) {
        setState(() {});

        context.push(
          '/set-new-password',
          extra: {'email': widget.email, 'code': code},
        );
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

  Future<void> _handleResendEmail() async {
    try {
      await _authService.forgotPassword(widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.t('verification_code_sent_to')} ${widget.email}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
                          context.go('/forgot-password');
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
                              localizations.t('verify_code'),
                              style: const TextStyle(fontFamily: 'Poppins', 
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
                              localizations.t('enter_4_digit_code'),
                              style: const TextStyle(fontFamily: 'Inter', 
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
                            return Text(
                              localizations.t('enter_code'),
                              style: const TextStyle(fontFamily: 'Poppins', 
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.disabled,
                                height: 1.6,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 6 digit code input
                    FadeTransition(
                      opacity: _fadeAnimations[1],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_fadeAnimations[1]),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (index) => _buildCodeBox(index),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

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
                            // Listen to all controllers for changes
                            return AnimatedBuilder(
                              animation: Listenable.merge(_controllers),
                              builder: (context, child) {
                                final code = _getCode();
                                return GradientButton(
                                  text: localizations.t('verify'),
                                  onPressed: _handleVerifyCode,
                                  enabled: code.length == 4,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

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
                            return Center(
                              child: TextButton(
                                onPressed: _handleResendEmail,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  localizations.t('resend_email'),
                                  style: const TextStyle(fontFamily: 'Poppins', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
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

  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 48,
      height: 54,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontFamily: 'Poppins', 
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surfaceInput,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) => _onCodeChanged(index, value),
      ),
    );
  }
}
