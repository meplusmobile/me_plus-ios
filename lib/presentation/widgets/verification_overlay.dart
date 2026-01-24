import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class VerificationOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const VerificationOverlay({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<VerificationOverlay> createState() => _VerificationOverlayState();

  /// Show the verification overlay on top of current screen
  static void show(
    BuildContext context, {
    VoidCallback? onComplete,
    Duration? duration,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => VerificationOverlay(
        onComplete: onComplete,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

class _VerificationOverlayState extends State<VerificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Scale animation for the card
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  Future<void> _dismissWithAnimation() async {
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 375,
                height: 316,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated GIF
                    Image.asset(
                      'assets/images/image.gif',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 32),

                    // Verification text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Builder(
                        builder: (context) {
                          final localizations = AppLocalizations.of(context)!;
                          return Column(
                            children: [
                              Text(
                                localizations.t('were_verifying_your_info'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.t('this_wont_take_long'),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
